require 'spec_helper'

describe "ActiveRecordTranslateable" do

    it "makes name translateable" do
      Something.class_eval { translate :foo }
      Something.translatable.should include(:foo)
    end

    context "class without translations" do
      it "saves" do
        foo = Foo.new
        foo.save.should be_true
      end
      it "loads" do
        foo = Foo.create!
        Foo.find(foo.id).should_not be_nil
      end
    end

    context "custom created methods" do
      it "responds to translated attributes" do
        something = Something.new
        something.should respond_to(:name)
        something.should respond_to(:name=)
        something.should respond_to(:name_de)
        something.should respond_to(:name_de=)
      end
    end

    context "attributes" do
      before(:each) do
        @locale = I18n.locale
      end

      after(:each) do
        I18n.locale = @locale
      end

      it "read/writes by hash assignment" do
        something = Something.new(name: "Something", name_de: "Etwas")
        something.name.should == "Something"
        something.name_de.should == "Etwas"
      end

      it "read/writes from database" do
        something = Something.create!(name: "Something", name_de: "Etwas")
        something.reload
        something.name.should == "Something"
        something.name_de.should == "Etwas"
      end

      it "reads by locale" do
        something = Something.create!(name_de: "Etwas")
        I18n.locale = :de
        something.name.should == "Etwas"
      end

      it "writes by locale" do
        I18n.locale = :de
        something = Something.create!(name: "Etwas", name_en: "Something")
        I18n.locale = :en
        something.name_de.should == "Etwas"
        something.name.should == "Something"
      end
    end

    context "store translations" do
      let(:something) { Something.create(name: "Something") }

      it "writes stored translations to the backend" do
        i18n_key = "something.name-#{something.id}"
        backend = double("Backend")
        I18n.stub(:backend).and_return(backend)
        backend.should_receive(:store_translations)
               .with(:en, { i18n_key => "Something" }, escape: false)
        something.save
      end

      it "should save the model without translations" do
        something = Something.new
        something.save.should be_true
      end

      it "should not include a read locale unless set to something" do
        something.name_gr
        something.locales.should_not include("gr")
      end
    end

    context "translation store" do
      before(:each) do
        @backend = double("Backend")
        I18n.stub(:backend).and_return(@backend)
      end
      it "is called on save" do
        @backend.should_receive(:store_translations).twice
        Something.new(name: 'something', name_de: 'etwas').save
      end

      it "is called on create" do
        @backend.should_receive(:store_translations).twice
        Something.create(name: 'something', name_de: 'etwas')
      end

      it "is called on update" do
        @backend.should_receive(:store_translations).exactly(4)
        sth = Something.create(name: 'something_old', name_de: 'etwas_old')
        sth.update_attributes(name: 'something', name_de: 'etwas')
      end
    end

    context "db array support" do
      it "works with native support" do
        something = Something.create!(name: "Something", name_de: "Etwas")
        something.reload.available_locales.should include(:en, :de)
      end

      it "works with serialize" do
        thing = Noarraything.create!(name: "thing", name_de: "ding")
        thing.reload.available_locales.should include(:en, :de)
      end
    end
end
