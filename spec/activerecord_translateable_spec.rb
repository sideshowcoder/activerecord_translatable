require 'spec_helper'

describe "ActiveRecordTranslateable" do

    it "should add name to translateable" do
      Something.translatable.should include(:name)
    end

    context "class without translations" do
      it "should save" do
        foo = Foo.new
        foo.save.should be_true
      end
      it "should load" do
        foo = Foo.create!
        Foo.find(foo.id).should_not be_nil
      end
    end


    context "translations" do
      before(:each) do
        @something = Something.create!(name: "Something")
        @locale = I18n.locale
      end

      after(:each) do
        I18n.locale = @locale
      end

      it "should get the translation from stored translations" do
        @something.set_translation("name", "Etwas", :de)
        @something.translations[:de]["name"].should == "Etwas"
      end

      it "should set the translation to the stored translations" do
        @something.set_translation("name", "Etwas", :de)
        @something.translation("name", :de).should == "Etwas"
      end

      it "should get the translation for the default I18n locale" do
        I18n.locale = :de
        @something.set_translation("name", "Etwas")
        @something.translation("name").should == "Etwas"
      end

      it "should set the translation for the default I18n locale" do
        I18n.locale = :de
        @something.set_translation("name", "Etwas")
        @something.translation("name", :de).should == "Etwas"
      end

      it "should write the stored translations to the backend" do
        backend = double("Backend")
        I18n.stub(:backend).and_return(backend)
        backend.should_receive(:store_translations).
          with(:en, { "something.name-#{@something.id}" => "Something" }, escape: false)
        @something.write_translations
      end

      it "should save the model without translations" do
        something = Something.new
        something.save.should be_true
      end

    end

    context "trigger save on model change" do
      before(:each) do
        @backend = double("Backend")
        I18n.stub(:backend).and_return(@backend)
      end
      it "should save translations on save" do
        @backend.should_receive(:store_translations).twice
        Something.new(name: 'something', name_de: 'etwas').save
      end

      it "should save translations on create" do
        @backend.should_receive(:store_translations).twice
        Something.create(name: 'something', name_de: 'etwas')
      end

      it "should save translations on update" do
        @backend.should_receive(:store_translations).exactly(4)
        sth = Something.create(name: 'something_old', name_de: 'etwas_old')
        sth.update_attributes(name: 'something', name_de: 'etwas')
      end
    end

    context "don't set locales on read" do
      let(:something) { Something.create!(name: "Something") }

      it "should not include a read locale unless set to something" do
        something.name_gr
        something.locales.should_not include("gr")
      end
    end

    context "custom created methods" do
      let(:something) { Something.create!(name: "Something") }

      it "should respond to translated attributes" do
        something.should respond_to(:name)
        something.should respond_to(:name=)
        something.should respond_to(:name_de)
        something.should respond_to(:name_de=)
      end

      it "should get the translated attributes" do
        something = Something.create!(name: "Something", name_de: "Etwas")
        something_from_db = Something.find(something.id)
        something_from_db.name.should == "Something"
        something_from_db.name_de.should == "Etwas"
      end

    end

    context "locales with db array support" do
      let(:something) { Something.create!(name: "Something") }

      it "should respond with available locales" do
        something.available_locales.should include(:en)
        something.name_de = "Etwas"
        something.available_locales.should include(:en, :de)
      end

    end

    context "locales without db array support" do
      let(:thing) { Noarraything.create!(name: "thing", name_de: "ding") }

      it "should store the locales as array" do
        locales = thing.locales
        thing.reload.locales.should == locales
      end
    end

end
