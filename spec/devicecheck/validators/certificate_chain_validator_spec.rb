# frozen_string_literal: true

RSpec.describe Devicecheck::Validators::CertificateChainValidator do
  subject { described_class.new(root_ca: root_certificate).validate(att_stmt) }

  let(:root_key) { generate_key }
  let(:root_dn) { OpenSSL::X509::Name.parse('/CN=Attestation Root CA') }
  let(:root_certificate) { generate_root_cert(root_dn, root_key) }

  let(:intermediate_key) { generate_key }
  let(:intermediate_dn) { OpenSSL::X509::Name.parse('/CN=Attestation CA 1') }
  let(:intermediate_serial) { 201 }
  let(:intermediate_not_after) { Time.now + 3600 }
  let(:intermediate_certificate) do
    cert = generate_cert(
      intermediate_dn,
      intermediate_key,
      intermediate_serial,
      issuer: root_certificate.subject,
      not_after: intermediate_not_after
    )

    mark_as_ca(cert)

    cert.sign(root_key, 'sha256')
    cert
  end

  let(:leaf_key) { generate_key }
  let(:leaf_dn) { OpenSSL::X509::Name.parse('/CN=Device') }
  let(:leaf_serial) { 301 }
  let(:leaf_not_after) { Time.now + 3600 }
  let(:leaf_certificate) do
    cert = generate_cert(
      leaf_dn,
      leaf_key,
      leaf_serial,
      issuer: intermediate_certificate.subject,
      not_after: leaf_not_after
    )
    cert.sign(intermediate_key, 'sha256')
    cert
  end

  let(:att_stmt) do
    {
      'x5c' => [leaf_certificate.to_der, intermediate_certificate.to_der]
    }
  end

  context 'when certificate chain is valid' do
    it 'returns first certificate in the x5c array' do
      expect(subject).to eq(leaf_certificate)
    end
  end

  context 'when certificate chain is not valid' do
    context 'when the leaf certificate has expired' do
      let(:leaf_not_after) { Time.now - 1 }

      it { is_expected.to be_nil }
    end

    context 'when the intermediate certificate has expired' do
      let(:intermediate_not_after) { Time.now - 1 }

      it { is_expected.to be_nil }
    end

    context 'when the intermediate certificate is missing' do
      let(:att_stmt) { { 'x5c' => [leaf_certificate.to_der] } }

      it { is_expected.to be_nil }
    end

    context 'when the root is not trusted' do
      subject { described_class.new(root_ca: other_root).validate(att_stmt) }

      let(:other_root) { generate_root_cert(OpenSSL::X509::Name.parse('/CN=Other Root'), generate_key) }

      it { is_expected.to be_nil }
    end

    context 'when the intermediate certificate is not properly signed' do
      let(:intermediate_certificate) do
        cert = generate_cert(intermediate_dn, intermediate_key, intermediate_serial, issuer: root_certificate.subject)
        mark_as_ca(cert)
        cert.sign(generate_key, 'sha256')
        cert
      end

      it { is_expected.to be_nil }
    end

    context 'when leaf certificate is not properly signed' do
      let(:some_other_key) { generate_key }

      let(:leaf_certificate) do
        cert = generate_cert(
          leaf_dn,
          leaf_key,
          leaf_serial,
          issuer: intermediate_certificate.subject,
          not_after: leaf_not_after
        )
        cert.sign(some_other_key, 'sha256')
        cert
      end

      it { expect(subject).to be_nil }
    end
  end
end
