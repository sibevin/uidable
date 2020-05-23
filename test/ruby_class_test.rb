class Admin
  include Uidable
  uidable
end

class Admin2
  include Uidable
  uidable uid_name: "uuid"
end

class Admin3
  include Uidable
  uidable read_only: false
end

class Admin4
  include Uidable
  uidable
  UID_SIZE = 128
  def gen_uid
    Array.new(UID_SIZE){[*'0'..'9'].sample}.join
  end
end

class MultiAdmin
  include Uidable
  uidable
  uidable uid_name: "slug"
end

class MultiAdmin2
  include Uidable
  uidable uid_name: "uuid"
  uidable uid_name: "slug"
  UID_SIZE = 128
  def gen_uuid
    Array.new(UID_SIZE){[*'0'..'9'].sample}.join
  end
end

describe Uidable do
  it "should respond to the uid attribute" do
    a = Admin.new
    expect(a.respond_to?(:uid)).must_equal true
  end

  it "should assign the uid with 32-bit length string when object is initalized" do
    a = Admin.new
    expect(a.uid).must_match(/^[a-z0-9]{#{Uidable::DEFAULT_UID_SIZE}}$/)
  end

  it 'should change the uid attribute name with given uid_name' do
    a = Admin2.new
    expect(a.respond_to?(:uid)).must_equal false
    expect(a).must_respond_to :uuid
    expect(a.uuid).must_match(/^[a-z0-9]{#{Uidable::DEFAULT_UID_SIZE}}$/)
  end

  describe "read-only" do
    it "should be read-only by default" do
      a = Admin.new
      expect { a.uid = "assigned_uid" }.must_raise NoMethodError
    end

    it "can change uid if read-only is disabled" do
      a = Admin3.new
      a.uid = "assigned_uid"
      expect(a.uid).must_equal "assigned_uid"
    end
  end

  it "can override uid generation by given a customized gen_uid method" do
    a = Admin4.new
    expect(a.uid.size).must_equal Admin4::UID_SIZE
    expect(a.uid).must_match(/^[0-9]{#{Admin4::UID_SIZE}}$/)
  end

  describe "multi" do
    it "should respond to the uid attribute" do
      a = MultiAdmin.new
      expect(a.respond_to?(:uid)).must_equal true
      expect(a.respond_to?(:slug)).must_equal true
    end

    it "should assign the uid with 32-bit length string when object is initalized" do
      a = MultiAdmin.new
      expect(a.uid).must_match(/^[a-z0-9]{#{Uidable::DEFAULT_UID_SIZE}}$/)
      expect(a.slug).must_match(/^[a-z0-9]{#{Uidable::DEFAULT_UID_SIZE}}$/)
      expect(a.uid).wont_equal a.slug
    end

    it 'should change the uid attribute name with given uid_name' do
      a = MultiAdmin2.new
      expect(a.respond_to?(:uid)).must_equal false
      expect(a).must_respond_to :uuid
      expect(a.slug).must_match(/^[a-z0-9]{#{Uidable::DEFAULT_UID_SIZE}}$/)
    end

    it "can override uid generation by given a customized gen_uid method" do
      a = MultiAdmin2.new
      expect(a.uuid.size).must_equal MultiAdmin2::UID_SIZE
      expect(a.uuid).must_match(/^[0-9]{#{MultiAdmin2::UID_SIZE}}$/)
    end
  end
end
