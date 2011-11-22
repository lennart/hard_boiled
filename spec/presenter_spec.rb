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

describe HardBoiled::Presenter do
  let(:egg) { 
    OpenStruct.new({:temperature => 25, :boil_time => 7, :colour => "white"})
  }

  it "should produce correct hash" do
    definition = described_class.define egg do
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

  context :nested do
    let(:egg_box) {
      OpenStruct.new({
        :eggs => [egg],
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
end