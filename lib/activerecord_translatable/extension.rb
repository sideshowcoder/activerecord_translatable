module ActiveRecordTranslatable
  extend ActiveSupport::Concern

  attr_accessor :translations

  def setup_locale(locale)
    locales = self.locales || []
    locales << locale.to_s
    self.locales = locales.uniq
    @translations ||= {}
    @translations[locale] ||= {}
  end

  def base_name
    self.class.name.downcase
  end

  def translatable
    self._translatable[base_name]
  end

  def available_locales
    self.locales.map { |locale| locale.to_sym }
  end

  def translation(attribute, locale = I18n.locale)
    setup_locale(locale)
    begin
      @translations[locale][attribute] ||= I18n.t("#{base_name}.#{attribute}-#{self.id}",
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
    return if @translations.nil? # there are no translations to be saved

    @translations.each do |locale, translations|
      translations.each do |attribute, value|
        I18n.backend.store_translations(locale, { "#{base_name}.#{attribute}-#{self.id}" => value }, escape: false)
      end
    end
  end

  def method_missing(method_name, *arguments, &block)
    translatable.each do |attribute|
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
    translatable.each do |attribute|
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
    cattr_accessor :_translatable
  end

  module ClassMethods
    def translatable
      self._translatable[base_name] ||= []
    end

    def base_name
      self.name.downcase
    end

    def translate(*attributes)
      self._translatable ||= Hash.new { |h,k| h[k] = [] }
      self._translatable[base_name] = translatable.concat(attributes)
    end
  end

end
