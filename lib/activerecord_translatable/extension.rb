module ActiveRecordTranslatable
  # = Add tranlatable attributes to ActiveRecord models
  #
  # ActiveRecordTranslatable add +translate+ method to ActiveRecord::Base
  # which is used to declare attributes as translatable
  #
  # Saving and loading translations works by using +<attribute>_<local>+ to
  # read and write the attribute
  #
  #   class Thing < ActiveRecord::Base
  #     translate :name
  #   end
  #
  #   @thing = Thing.new(name: 'Thing', name_de: 'Ding')
  #   @thing.name # => Thing
  #   @thing.name_de # => Ding
  #
  # It works in conjunction with I18n.local
  #
  #   I18n.locale = :de
  #   @thing.name # => Ding
  #
  # Translations are stored the setup I18n.backend

  extend ActiveSupport::Concern

  ##
  # Translatable attributes for this model

  def translatable
    self._translatable[base_name]
  end

  ##
  # Locales available for this model
  # a locale is available if at least one attribute is present in given locale

  def available_locales
    self.locales.map { |locale| locale.to_sym }
  end

  ##
  # Define accessores

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
    ##
    # Define attribute as translatable
    #
    #   class Thing < ActiveRecord::Base
    #     translate :name
    #   end

    def translate(*attributes)
      self._translatable ||= Hash.new { |h,k| h[k] = [] }
      self._translatable[base_name] = translatable.concat(attributes).uniq
    end

    ##
    # Attributes defined as translatable

    def translatable
      self._translatable[base_name] ||= []
    end

    private
    def base_name
      self.name.downcase
    end
  end

  private
  def setup_locale(locale)
    locales = self.locales || []
    locales << locale.to_s
    self.locales = locales.uniq
  end

  def translations
    @translations ||= Hash.new { |h,k| h[k] = {} }
  end

  def base_name
    self.class.name.downcase
  end

  def translation(attribute, locale = I18n.locale)
    begin
      translation = translations.fetch(locale).fetch(attribute)
    rescue KeyError
      _get_stored_translation(attribute, locale)
    end
  end

  def _get_stored_translation(attribute, locale)
    begin
      translation = I18n.t("#{base_name}.#{attribute}-#{self.id}", locale: locale, raise: true)
      setup_locale(locale)
      translations[locale][attribute] = translation
    rescue I18n::MissingTranslationData
      nil
    end
  end

  def set_translation(attribute, value, locale = I18n.locale)
    setup_locale(locale)
    translations[locale][attribute] = value
  end

  def write_translations
    return if translations.empty? # there are no translations to be saved

    translations.each do |locale, trans|
      trans.each do |attribute, value|
        I18n.backend.store_translations(locale, { "#{base_name}.#{attribute}-#{self.id}" => value }, escape: false)
      end
    end
  end

end
