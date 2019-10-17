# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Cocina::Models::File do
  let(:file_type) { 'http://cocina.sul.stanford.edu/models/file.jsonld' }

  describe 'initialization' do
    subject(:item) { described_class.new(properties) }

    context 'with a minimal set' do
      let(:properties) do
        {
          externalIdentifier: 'druid:ab123cd4567',
          type: file_type,
          label: 'My file',
          version: 3
        }
      end

      it 'has properties' do
        expect(item.externalIdentifier).to eq 'druid:ab123cd4567'
        expect(item.type).to eq file_type
        expect(item.label).to eq 'My file'
      end
    end

    context 'with a string version' do
      let(:properties) do
        {
          externalIdentifier: 'druid:ab123cd4567',
          type: file_type,
          label: 'My file',
          version: '3'
        }
      end

      it 'coerces to integer' do
        expect(item.version).to eq 3
      end
    end

    context 'with a all properties' do
      let(:properties) do
        {
          externalIdentifier: 'druid:ab123cd4567',
          type: file_type,
          label: 'My file',
          version: 3,
          administrative: {
          },
          hasMessageDigests: [
            {
              type: 'md5',
              digest: 'd57db4241d7da0eecba5b33abf13f448'
            },
            {
              type: 'sha1',
              digest: '600a43324ea40ae1ba0c7ffa83965830d384c086'
            }
          ]
        }
      end

      it 'has properties' do
        expect(item.externalIdentifier).to eq 'druid:ab123cd4567'
        expect(item.type).to eq file_type
        expect(item.label).to eq 'My file'

        expect(item.hasMessageDigests).to all(be_kind_of(Cocina::Models::File::Fixity))
        fixity = item.hasMessageDigests.first
        expect(fixity.type).to eq 'md5'
        expect(fixity.digest).to eq 'd57db4241d7da0eecba5b33abf13f448'
      end
    end
  end

  describe '.from_dynamic' do
    subject(:item) { described_class.from_dynamic(properties) }

    context 'with empty subschemas' do
      let(:properties) do
        {
          'externalIdentifier' => 'druid:kv840rx2720',
          'type' => file_type,
          'label' => 'Examination of the memorial of the owners and underwriters ...',
          'version' => 1,
          'access' => {},
          'hasMessageDigests' => [
            {
              'type' => 'md5',
              'digest' => 'd57db4241d7da0eecba5b33abf13f448'
            }
          ],
          'identification' => {},
          'structural' => {}
        }
      end

      it 'has properties' do
        expect(item.externalIdentifier).to eq 'druid:kv840rx2720'
      end
    end
  end

  describe '.from_json' do
    subject(:dro) { described_class.from_json(json) }

    context 'with a minimal object' do
      let(:json) do
        <<~JSON
          {
            "externalIdentifier":"druid:12343234",
            "type":"#{file_type}",
            "label":"my item",
            "version": 3
          }
        JSON
      end

      it 'has the attributes' do
        expect(dro.attributes).to include(externalIdentifier: 'druid:12343234',
                                          label: 'my item',
                                          type: file_type)
        expect(dro.identification).to be_kind_of Cocina::Models::File::Identification
        expect(dro.structural).to be_kind_of Cocina::Models::File::Structural
      end
    end

    context 'with a full object' do
      let(:json) do
        <<~JSON
          {
            "externalIdentifier":"druid:12343234",
            "type":"#{file_type}",
            "label":"nrs_19180211_0003.tiff",
            "size":25243531,
            "version": 3,
            "use": "original",
            "presentation": {
              "height":5679,
              "width":4437
            },
            "hasMessageDigests": [
              {
                "type":"md5",
                "digest":"d57db4241d7da0eecba5b33abf13f448"
              },
              {
                "type":"sha1",
                "digest":"600a43324ea40ae1ba0c7ffa83965830d384c086"
              }
            ]
          }
        JSON
      end

      it 'has the attributes' do
        expect(dro.attributes).to include(externalIdentifier: 'druid:12343234',
                                          label: 'nrs_19180211_0003.tiff',
                                          type: file_type)

        digests = dro.hasMessageDigests
        expect(digests).to all(be_instance_of Cocina::Models::File::Fixity)
        expect(digests.first.type).to eq 'md5'

        expect(dro.presentation.height).to eq 5679
        expect(dro.presentation.width).to eq 4437
        expect(dro.size).to eq 25_243_531
        expect(dro.use).to eq 'original'
      end
    end
  end
end