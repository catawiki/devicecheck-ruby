# frozen_string_literal: true

RSpec.describe Devicecheck::Attestation do
  subject do
    described_class.new(app_id:, environment:).attest(
      key_id:,
      attestation_object:, challenge:
    )
  end

  let(:app_id) { 'com.example.foo' }
  let(:pkey) { OpenSSL::PKey::EC.generate('prime256v1') }

  let(:challenge) { SecureRandom.hex }

  let(:environment) { :development }

  let(:attestation_object) do
    Base64.strict_encode64(
      CBOR.encode(
        {
          'attStmt' => att_stmt,
          'authData' => auth_data
        }
      )
    )
  end

  let(:att_stmt) do
    {
      'x5c' => x5c,
      'receipt' => receipt
    }
  end
  let(:receipt) { 'receipt' }
  let(:x5c) { [cred_cert.to_der] }

  let(:auth_data) { 'fake-auth-data' }

  let(:root_key) { generate_key }
  let(:root_dn) { OpenSSL::X509::Name.parse('/CN=Attestation Root CA') }
  let(:root_certificate) { generate_root_cert(root_dn, root_key) }

  let(:cred_key) { generate_key }
  let(:cred_dn) { OpenSSL::X509::Name.parse('/CN=Device') }

  let(:client_data_hash) { OpenSSL::Digest::SHA256.digest(challenge) }
  let(:nonce) { OpenSSL::Digest::SHA256.digest(auth_data + client_data_hash) }
  let(:extension_data) do
    OpenSSL::ASN1::Sequence.new(
      [OpenSSL::ASN1::Sequence.new([OpenSSL::ASN1::OctetString.new(nonce)])]
    )
  end

  let(:key_id) do
    Base64.strict_encode64(OpenSSL::Digest::SHA256.digest(cred_key.public_key.to_octet_string(:uncompressed)))
  end

  let(:cred_cert) do
    cert = generate_cert(
      cred_dn,
      cred_key,
      10,
      issuer: root_certificate.subject
    )
    cert.sign(root_key, 'sha256')
    cert.add_extension(OpenSSL::X509::Extension.new('1.2.840.113635.100.8.2', extension_data))
    cert
  end

  let(:rp_id_hash) { OpenSSL::Digest::SHA256.digest(app_id) }
  let(:sign_count) { 0 }
  let(:aaguid) { 'appattestdevelop' }
  let(:credential_id) { OpenSSL::Digest::SHA256.digest(cred_key.public_key.to_octet_string(:uncompressed)) }
  let(:decoded_auth_data) { [rp_id_hash, nil, sign_count, aaguid, credential_id] }

  context 'with a complete attestation' do
    let(:auth_data) do
      [rp_id_hash, 0, sign_count, aaguid, credential_id.bytesize, credential_id].pack('a32cNa16na*')
    end

    let(:cred_cert) do
      cert = generate_cert(cred_dn, cred_key, 10, issuer: root_certificate.subject)
      cert.add_extension(OpenSSL::X509::Extension.new('1.2.840.113635.100.8.2', extension_data))
      cert.sign(root_key, 'sha256')
      cert
    end

    before do
      stub_const('Devicecheck::Validators::CertificateChainValidator::ROOT_CA', root_certificate)
    end

    it 'validates the certificate and authenticator data and returns the public key and receipt' do
      expect(subject).to eq([cred_key.public_to_der, receipt])
    end
  end

  context 'when data is valid' do
    before do
      allow(Devicecheck::Validators::CertificateChainValidator).to(
        receive(:validate).with(att_stmt).and_return(cred_cert)
      )
      allow(Devicecheck::Data::AuthenticatorData).to(receive(:unpack).with(auth_data).and_return(decoded_auth_data))
    end

    it 'returns the public key DER and receipt' do
      expect(subject).to eq([cred_key.to_der, receipt])
    end

    context 'when production mode' do
      let(:environment) { :production }
      let(:aaguid) { "appattest\0\0\0\0\0\0\0" }

      it 'returns the public key DER and receipt' do
        expect(subject).to eq([cred_key.to_der, receipt])
      end
    end
  end

  context 'when data is invalid' do
    context 'when certificate chain is invalid' do
      before do
        allow(Devicecheck::Validators::CertificateChainValidator).to(
          receive(:validate).with(att_stmt).and_return(nil)
        )
      end

      it { expect { subject }.to raise_error 'Failed certificate chain check' }
    end

    context 'when certificate chain is valid' do
      before do
        allow(Devicecheck::Validators::CertificateChainValidator).to(
          receive(:validate).with(att_stmt).and_return(cred_cert)
        )
        allow(Devicecheck::Data::AuthenticatorData).to(
          receive(:unpack).with(auth_data).and_return(decoded_auth_data)
        )
      end

      context 'when challenge is invalid' do
        let(:extension_data) do
          OpenSSL::ASN1::Sequence.new(
            [OpenSSL::ASN1::Sequence.new([OpenSSL::ASN1::OctetString.new(SecureRandom.hex)])]
          )
        end

        it { expect { subject }.to raise_error 'Failed challenge check' }
      end

      context 'when key_id invalid' do
        let(:key_id) do
          Base64.strict_encode64(OpenSSL::Digest::SHA256.digest(SecureRandom.hex))
        end

        it { expect { subject }.to raise_error 'Failed key ID check' }
      end

      context 'when auth data is invalid' do
        context 'when RP ID is invalid' do
          let(:rp_id_hash) { OpenSSL::Digest::SHA256.digest(SecureRandom.hex) }

          it { expect { subject }.to raise_error 'Failed RP ID check' }
        end

        context 'when sign count is not zero' do
          let(:sign_count) { 1 }

          it { expect { subject }.to raise_error 'Failed sign counter = 0 check' }
        end

        context 'when AAGUID is invalid' do
          let(:aaguid) { 'unknown' }

          it { expect { subject }.to raise_error 'Failed AAGUID check' }
        end

        context 'when credential ID is invalid' do
          let(:credential_id) { OpenSSL::Digest::SHA256.digest(SecureRandom.hex) }

          it { expect { subject }.to raise_error 'Failed credentialId check' }
        end
      end
    end
  end
end
