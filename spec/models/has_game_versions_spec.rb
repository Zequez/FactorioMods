require 'rails_helper'

RSpec.describe Mod do
  subject(:klass) { Mod }

  it { expect(klass.new).to respond_to :game_versions_string }

  it { expect(klass.new).to respond_to :game_versions }
end