module Translatable
  extend ActiveSupport::Concern

  attr_accessor :translations

  def setup_locale(locale)
    locales = self.locales || []
    locales << locale.to_s
    self.locales = locales.uniq
    @translations ||= {}
    @translations[locale] ||= {}
  end

  def available_locales
    self.locales.map { |locale| locale.to_sym }   
  end

  def translation(attribute, locale = I18n.locale)
    setup_locale(locale)
    begin
      @translations[locale][attribute] ||= I18n.t("#{self.base_name}.#{attribute}-#{self.id}",
                                                  locale: locale, raise: true)
    rescue I18n::MissingTranslationData
      @translations[locale][attribute]
    end
  end

  def set_translation(attribute, value, locale = I18n.locale)
    setup_locale(locale)
    @translations[locale][attribute] = value
  end
  
  def write_translations
    @translations.each do |locale, translations|
      translations.each do |attribute, value|
        I18n.backend.store_translations(locale, { "#{self.base_name}.#{attribute}-#{self.id}" => value }, escape: false)
      end
    end
  end

  def method_missing(method_name, *arguments, &block)
    self.translateable.each do |attribute|
      attribute = attribute.to_s
      if method_name.to_s =~ /^#{attribute}_(.{2})=$/
        return set_translation(attribute, arguments.first, $1.to_sym)
      elsif method_name.to_s =~ /^#{attribute}=$/
        return set_translation(attribute, arguments.first)
      elsif method_name.to_s =~ /^#{attribute}_(.{2})$/
        return translation(attribute, $1.to_sym)
      elsif method_name.to_s =~ /^#{attribute}$/
        return translation(attribute)
      end
    end
    super
  end
  
  def respond_to_missing?(method_name, include_private = false)
    self.translateable.each do |attribute|
      attribute = attribute.to_s
      if method_name.to_s =~ /^#{attribute}_(.{2})=$/
        return true
      elsif method_name.to_s =~ /^#{attribute}=$/
        return true
      elsif method_name.to_s =~ /^#{attribute}_(.{2})$/
        return true
      elsif method_name.to_s =~ /^#{attribute}$/
        return true
      end
    end
    false
  end

  included do
    after_save :write_translations
    cattr_accessor :translateable, :base_name
  end

  module ClassMethods
    def translate(*attributes)
      self.base_name = self.name.downcase
      self.translateable ||= []
      self.translateable = self.translateable.concat(attributes)
    end
  end

end
