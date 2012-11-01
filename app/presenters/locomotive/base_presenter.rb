class Locomotive::BasePresenter

  include ActionView::Helpers::SanitizeHelper
  extend  ActionView::Helpers::SanitizeHelper::ClassMethods
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::NumberHelper

  include ActiveModel::Validations
  extend ActiveModel::Callbacks

  define_model_callbacks :save
  define_model_callbacks :validation
  define_model_callbacks :source_validation

  attr_reader :source, :options, :ability, :depth

  delegate :created_at, :updated_at, :to => :source

  def initialize(object, options = {})
    @source   = object
    @options  = options || {}
    @depth    = options[:depth] || 0
    @ability  = options[:ability]

    if @options[:current_account] && @options[:current_site]
      @ability = Locomotive::Ability.new @options[:current_account], @options[:current_site]
    end
  end

  def id
    self.source.persisted? || self.source.embedded? ? self.source._id.to_s : nil
  end

  alias :_id :id

  def valid?(*args)
    run_callbacks :validation do
      super
      run_callbacks :source_validation do
        self.source.valid?
        self.source.errors.each do |attribute, error|
          self.errors.add(attribute, error)
        end
      end
    end
    self.errors.empty?
  end

  def ability?
    self.ability.present?
  end

  def included_methods
    %w(id _id created_at updated_at)
  end

  def included_setters
    []
  end

  def included_setter_methods
    included_setters.collect do |setter|
      :"#{setter}="
    end
  end

  def as_json(methods = nil)
    methods ||= self.included_methods
    {}.tap do |hash|
      methods.each do |meth|
        hash[meth] = json_value_for_attribute(meth.to_s)
      end
    end
  end

  def to_json(options = {})
    self.as_json.to_json(options)
  end

  def assign_attributes(new_attributes)
    return unless new_attributes

    new_attributes.each do |attr, value|
      # Only call the methods which the presenter can handle
      meth = :"#{attr}="
      if self.included_setter_methods.include? meth
        self.send(meth, value)
      end
    end
  end

  def update_attributes(new_attributes)
    self.assign_attributes(new_attributes)
    self.save
  end

  def save(options = {})
    options = {
      validate: true
    }.merge(options)

    return false if options[:validate] && self.invalid?

    result = false
    run_callbacks :save do
      result = self.source.save
    end
    result
  end

  protected

  # Subclasses can override this method to specify the value for a particular
  # key in the hash returned by as_json
  def json_value_for_attribute(attr)
    self.send(:"#{attr}") rescue nil
  end

end
