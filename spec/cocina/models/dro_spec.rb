# frozen_string_literal: true

require 'spec_helper'
load 'spec/cocina/models/dro_shared_examples.rb'

RSpec.describe Cocina::Models::DRO do
  let(:item_type) { Cocina::Models::Vocab.object }
  let(:required_properties) do
    {
      externalIdentifier: 'druid:bc123df4567',
      label: 'My object',
      type: item_type,
      version: 2,
      access: {}
    }
  end
  let(:struct_class) { Cocina::Models::DROStructural }
  let(:struct_contains_class) { Cocina::Models::FileSet }
  let(:struct_contains_properties) do
    [
      { type: file_set_type,
        version: 1,
        externalIdentifier: '12343234_1',
        label: 'Resource #1' },
      { type: file_set_type,
        version: 2,
        externalIdentifier: '12343234_2',
        label: 'Resource #2' }
    ]
  end

  it_behaves_like 'it has dro attributes'

  context 'when externalIdentifier is missing' do
    let(:fileset) { described_class.new(required_properties.reject { |k, _v| k == :externalIdentifier }) }

    it 'raises a Cocina::Models::ValidationError' do
      expect { fileset }.to raise_error(Cocina::Models::ValidationError)
    end
  end

  describe 'Checkable model methods' do
    subject { described_class.new(required_properties) }

    it { is_expected.not_to be_admin_policy }
    it { is_expected.not_to be_collection }
    it { is_expected.to be_dro }
    it { is_expected.not_to be_file }
    it { is_expected.not_to be_file_set }
  end

  describe Cocina::Models::DROStructural do
    let(:instance) { described_class.new(properties) }

    context 'with FileSet as contained class' do
      let(:properties) do
        {
          contains: [
            struct_contains_class.new(
              externalIdentifier: 'fileset#1',
              label: 'fileset#1',
              type: Cocina::Models::Vocab.fileset,
              version: 1
            )
          ]
        }
      end

      it 'populates passed attrbutes for File' do
        expect(instance.contains).to all(be_kind_of(struct_contains_class))
        fileset1 = instance.contains.first
        expect(fileset1.type).to eq Cocina::Models::Vocab.fileset
        expect(fileset1.label).to eq 'fileset#1'
        expect(fileset1.version).to eq 1
        expect(fileset1.externalIdentifier).to eq 'fileset#1'
      end
    end

    context 'with RequestFileSet as contained class' do
      let(:properties) do
        {
          contains: [
            Cocina::Models::RequestFileSet.new(
              label: 'requestfileset#2',
              type: Cocina::Models::Vocab.fileset,
              version: 2
            )
          ]
        }
      end

      it 'raises a Dry::Struct::Error' do
        expect { instance }.to raise_error(Dry::Struct::Error)
      end
    end
  end

  # describe '.image?' do
  #   subject(:item) { described_class.new(properties) }
  #
  #   let(:properties) do
  #     {
  #       externalIdentifier: 'druid:ab123cd4567',
  #       type: item_type,
  #       label: 'My object',
  #       version: 3,
  #       description: {
  #         title: []
  #       },
  #       structural: {
  #         hasAgreement: ''
  #       }
  #     }
  #   end
  #
  #   it { is_expected.not_to be_image }
  #
  #   context 'when it has the image type' do
  #     let(:item_type) { 'http://cocina.sul.stanford.edu/models/image.jsonld' }
  #
  #     it { is_expected.to be_image }
  #   end
  # end
end
