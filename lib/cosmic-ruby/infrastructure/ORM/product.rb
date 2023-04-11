require 'active_record'
require 'cosmic-ruby/domain/product'
require 'cosmic-ruby/infrastructure/ORM/batch'

class VersionValidator < ActiveModel::Validator
  def validate(record)
    persisted = ORM::Product.find_by sku: record.sku
    if persisted && persisted.version >= record.version
      record.errors.add :version, ("version already exists")
    end
  end
end

module ORM
  ProductModel = Product
  class Product < ActiveRecord::Base
    validates_with VersionValidator
    has_many :batches
    attr_accessor :model

    def self.from model
      orm = ORM::Product.new(
        id: model.id,
        sku: model.sku.sku,
        version: model.version,
        batches: model.batches.map { |batch| ORM::Batch.from batch })
      orm
    end

    def self.to_model orm_model
      ProductModel.new(
        Sku.new(orm_model.sku),
        orm_model.batches.map { |batch| ORM::Batch.to_model batch },
        orm_model.id,
        orm_model.version)
    end

    def _save model
        self.sku = model.sku.sku
        self.version = model.version
        self.batches = self.batches.reject { |orm_batch| !model.batches.map(&:id).include?(orm_batch.id) }
        self.batches.each do |orm_batch|
            batch = model.batches.find { |batch| orm_batch.id == batch.id }
            orm_batch._update batch
          end
        model.batches
             .reject(&:id)
             .each { |order_line| self.batches << ORM::Batches.from(order_line, self.id) }
        save!
    end
  end
end