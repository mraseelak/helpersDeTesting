# frozen_string_literal: true

require 'rspec'
require 'spec_helper'

RSpec.describe TestHelpers::Hiptest do
  describe '#configure_project!' do
    context 'with valid data' do
      let(:setup) do
        {
          project: 1231,
          access_token: 23_492_309,
          client: 98_032_984,
          uid: 'me@example.com'
        }
      end

      let(:headers) do
        {
          Accept: 'application/vnd.api+json; version=1',
          "access-token": 23_492_309,
          client: 98_032_984,
          uid: 'me@example.com'
        }
      end

      before do
        TestHelpers::Hiptest.configure_project!(**setup)
      end

      specify { expect(TestHelpers::Hiptest.project).to eql(1231) }
      specify { expect(TestHelpers::Hiptest::Scenarios.headers).to eql(headers) }
      specify { expect(TestHelpers::Hiptest::TestRuns.options[:headers]).to eql(headers) }
    end

    context 'with missing data' do
      specify do
        expect do
          TestHelpers::Hiptest.configure_project!
        end.to raise_error(ArgumentError, 'missing keywords: :project, :access_token, :client, :uid')
      end
      specify do
        expect do
          TestHelpers::Hiptest.configure_project!(project: 12_312)
        end.to raise_error(ArgumentError, 'missing keywords: :access_token, :client, :uid')
      end
      specify do
        expect do
          TestHelpers::Hiptest.configure_project!(project: 12_312,
                                                  access_token: 23_423)
        end.to raise_error(ArgumentError, 'missing keywords: :client, :uid')
      end
      specify do
        expect do
          TestHelpers::Hiptest.configure_project!(project: 12_312, access_token: 23_423,
                                                  client: 9879)
        end.to raise_error(ArgumentError, 'missing keyword: :uid')
      end
    end
  end
end

RSpec.describe TestHelpers::Hiptest::Scenarios do
  let(:headers) do
    {
      Accept: 'application/vnd.api+json; version=1',
      "access-token": 23_492_309,
      client: 98_032_984,
      uid: 'me@example.com'
    }
  end
  describe '#setup_scenarios' do
    it 'splits the tags into an array' do
      TestHelpers::Hiptest::Scenarios.setup_scenarios(project: 1011, tags: 'tag1, tag2', headers: headers)
      expect(TestHelpers::Hiptest::Scenarios.tags).to eql(%w[tag1 tag2])
    end
  end

  describe '#collect_scenarios_by_tags' do
    it 'should raise error if tag is not provided' do
      TestHelpers::Hiptest::Scenarios.tags = nil
      expect { TestHelpers::Hiptest::Scenarios.collect_scenarios_by_tags }.to raise_error('Tag(s) not provided')
    end
  end
end

RSpec.describe TestHelpers::Hiptest::TestRuns do
  describe '#separate_tags' do
    specify 'separate the string into single key value pair' do
      TestHelpers::Hiptest::TestRuns.instance_variable_set(:@list, 'PA:1234')
      expect(TestHelpers::Hiptest::TestRuns.separate_tags).to eql('PA' => '1234')
    end

    specify 'returns nil if the list is zero length' do
      TestHelpers::Hiptest::TestRuns.instance_variable_set(:@list, [])
      TestHelpers::Hiptest::TestRuns.instance_variable_set(:@build, 'ABC')
      expect(TestHelpers::Hiptest::TestRuns.separate_tags).to be_nil
    end

    specify 'returns nil if the list is nil' do
      TestHelpers::Hiptest::TestRuns.instance_variable_set(:@list, nil)
      TestHelpers::Hiptest::TestRuns.instance_variable_set(:@build, 'ABC')
      expect(TestHelpers::Hiptest::TestRuns.separate_tags).to be_nil
    end

    specify 'should separate the string into multiple key value pairs' do
      TestHelpers::Hiptest::TestRuns.instance_variable_set(:@list, 'PA:1234,PB:324')
      expect(TestHelpers::Hiptest::TestRuns.separate_tags).to eql('PA' => '1234', 'PB' => '324')
    end
  end

  describe '#add_tags_to_id' do
  end
end
