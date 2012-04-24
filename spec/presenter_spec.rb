require File.dirname(__FILE__) + '/spec_helper'

module MyFilters
  def upcase value
    value.upcase
  end

  def twice_and_a_half value
    value * 2.5
  end
end

class Filterable < HardBoiled::Presenter
  include MyFilters
end

class Calculator
  def add a, b
    a + b
  end

  def zero
    0
  end

  def negative
    -100
  end

  def tax val = 0.0
    ((val + 1) * 2700).to_i
  end
end

describe HardBoiled::Presenter do
  let(:egg) {
    OpenStruct.new({:temperature => 25, :boil_time => 7, :colour => "white"})
  }

  let(:conventional_egg) {
    OpenStruct.new({:temperature => 25, :boil_time => 5,
      :colour => "brownish", :organic => false})
  }

  it "should produce correct hash" do
    definition = described_class.define(egg) do
      colour
      time :from => :boil_time
      consumer "Lennart"
    end

    definition.should == {
      :colour => "white",
      :time => 7,
      :consumer => "Lennart"
    }
  end

  context :paramified do
    it "should pass params to member function" do
      definition = described_class.define(Calculator.new) do
        negative
        zero
        add :params => [5, 2]
      end

      definition.should == {
        :negative => -100,
        :zero => 0,
        :add => 7
      }
    end

    it "should pass param to member function" do
      definition = described_class.define(Calculator.new) do
        null :from => :zero
        tax
        sales :from => :tax, :params => 0.19
      end

      definition.should == {
        :null => 0,
        :tax => 2700,
        :sales => 3213
      }
    end
  end

  context :nested do
    let(:egg_box) {
      OpenStruct.new({
        :eggs => [egg, conventional_egg],
        :flavour => "extra tasty",
        :packaged_at => "2011-11-22"
      })
    }

    it "should allow nested objects" do
      definition = Filterable.define egg_box do
        contents :from => :eggs do
          colour
          time :from => :boil_time, :filters => [:twice_and_a_half], :format => "%.2f minutes"
          taste :from => :flavour, :parent => true
          consumer "Lennart", :filters => [:upcase]
          "Return value has to be ignored"
        end

        date :from => :packaged_at, :format => "on %s"
      end

      definition.should == {
        :contents => [
          {
            :colour => "white",
            :time => "17.50 minutes",
            :consumer => "LENNART",
            :taste => "extra tasty"
          },
          {
            :colour => "brownish",
            :time => "12.50 minutes",
            :consumer => "LENNART",
            :taste => "extra tasty"
          }
        ],
        :date => "on 2011-11-22"
      }
    end
  end

  context :filtering do
    it "should apply filters" do
      definition = Filterable.define egg do
        colour :filters => [:upcase]
        time :from => :boil_time
        consumer "Lennart"
      end

      definition.should == {
        :colour => "WHITE",
        :time => 7,
        :consumer => "Lennart"
      }
    end

    it "should raise on missing filter" do
      expect {
        definition = described_class.define egg do
          colour :filters => [:upcase]
          time :from => :boil_time
          consumer "Lennart"
        end
      }.to raise_error(HardBoiled::Presenter::MissingFilterError)
    end

  end

  context :defaults do
    def with_defaults obj
      Filterable.define obj do
        colour :filters => [:upcase]
        time :from => :boil_time
        consumer "Lennart"
        organic :default => true
      end
    end

    it "should fallback to defaults" do
      with_defaults(egg).should == {
        :colour => "WHITE",
        :time => 7,
        :consumer => "Lennart",
        :organic => true
      }
    end

    it "should still use defined values" do
      with_defaults(conventional_egg).should == {
        :colour => "BROWNISH",
        :time => 5,
        :consumer => "Lennart",
        :organic => false
      }
    end
  end

  context :traits do
    def with_traits obj, options = {}
      Filterable.define(obj, options) {
        with_trait(:instructions) {
          with_trait(:timing) {
            boil_time
          }
          temperature
        }
        with_trait(:presentation) {
          colour
        }
      }
    end

    it "should just map instructions" do
      with_traits(egg, :only => [:instructions]).should == {
        :temperature => 25
      }
    end

    it "should map everything except for timing information" do
      with_traits(egg, :except => [:timing]).should == {
        :colour => "white",
        :temperature => 25
      }
    end
  end
end