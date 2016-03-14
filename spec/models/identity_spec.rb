require "rails_helper"

RSpec.describe Identity, type: :model do

  it { is_expected.to have_one(:identity_counter) }

  it { is_expected.to have_many(:documents) }
  it { is_expected.to have_many(:project_roles) }
  it { is_expected.to have_many(:clinical_providers) }

  describe "#protocols" do

    context "Protocols present for clinical_provider organization" do

      it "should return an array of Protocols" do
        identity            = create(:identity)
        organization        = create(:organization)
        sub_service_request = create(:sub_service_request, organization: organization)
        protocol            = create(:protocol, sub_service_request: sub_service_request)

        create(:clinical_provider, identity: identity, organization: organization)

        expect(identity.protocols.length).to eq(1)
      end
    end

    context "Protocols present for clinical_provider and super_user organizations" do

      it "should return an array of Protocols" do
        identity            = create(:identity)
        cp_organization        = create(:organization)
        cp_sub_service_request = create(:sub_service_request, organization: cp_organization)
        cp_protocol            = create(:protocol, sub_service_request: cp_sub_service_request)

        su_organization        = create(:organization)
        su_sub_service_request = create(:sub_service_request, organization: su_organization)
        su_protocol            = create(:protocol, sub_service_request: su_sub_service_request)

        create(:clinical_provider, identity: identity, organization: cp_organization)
        create(:super_user, identity: identity, organization: su_organization)
  
        expect(identity.protocols.length).to eq(2)
      end
    end

    context "no Protocols present" do

      it "should return an empty array" do
        identity        = create(:identity)
        organization    = create(:organization)
        service_request = create(:service_request)
        create(:sub_service_request, organization: organization, service_request: service_request)
        create(:clinical_provider, identity: identity, organization: organization)

        expect(identity.protocols).to eq([])
      end
    end
  end

  describe '.identity_counter' do

    context "IdentityCounter exists" do

      it "should not create a new IdentityCounter" do
        identity = create(:identity_with_counter)
        expect(identity.identity_counter).to be
        expect(IdentityCounter.count).to eq(1)
      end
    end

    context "IdentityCounter does not exist" do

      it "should create an IdentityCounter if it does not exist" do
        identity = create(:identity)
        expect(identity.identity_counter).to be
        expect(IdentityCounter.count).to eq(1)
      end
    end
  end

  describe '.tasks_count' do

    it "should be delegated to identity_counter" do
      identity = create(:identity)
      expect(identity.tasks_count).to be(0)
    end
  end

  describe '#clinical_provider_organizations_with_protocols' do

    it "should return organizations that have a clinical provider on them AND have protocols." do
      identity            = create(:identity)
      cp_organization        = create(:organization)
      cp_sub_service_request = create(:sub_service_request, organization: cp_organization)
      cp_protocol            = create(:protocol, sub_service_request: cp_sub_service_request)

      create(:clinical_provider, identity: identity, organization: cp_organization)


      expect(identity.clinical_provider_organizations_with_protocols.first.id).to eq(cp_organization.id)
    end
  end
end
