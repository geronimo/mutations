require_relative 'spec_helper'

describe "Mutations::HashFilter" do

  it "allows valid hashes" do
    hf = Mutations::HashFilter.new do
      string :foo
    end
    filtered, errors = hf.filter(foo: "bar")
    assert_equal ({"foo" => "bar"}), filtered
    assert_equal nil, errors
  end
  
  it 'disallows non-hashes' do
    hf = Mutations::HashFilter.new do
      string :foo
    end
    filtered, errors = hf.filter("bar")
    assert_equal :hash, errors
  end
  
  it "allows wildcards in hashes" do
    hf = Mutations::HashFilter.new do
      string :*
    end
    filtered, errors = hf.filter(foo: "bar", baz: "ban")
    assert_equal ({"foo" => "bar", "baz" => "ban"}), filtered
    assert_equal nil, errors
  end
  
  it "doesn't allow wildcards in hashes" do
    hf = Mutations::HashFilter.new do
      string :*
    end
    filtered, errors = hf.filter(foo: [])
    assert_equal ({"foo" => :string}), errors.symbolic
  end
  
  it "allows a mix of specific keys and then wildcards" do
    hf = Mutations::HashFilter.new do
      string :foo
      integer :*
    end
    filtered, errors = hf.filter(foo: "bar", baz: "4")
    assert_equal ({"foo" => "bar", "baz" => 4}), filtered
    assert_equal nil, errors
  end
  
  it "doesn't allow a mix of specific keys and then wildcards -- should raise errors appropriately" do
    hf = Mutations::HashFilter.new do
      string :foo
      integer :*
    end
    filtered, errors = hf.filter(foo: "bar", baz: "poopin")
    assert_equal ({"baz" => :integer}), errors.symbolic
  end
  
  describe "a hash filter with optional params" do
    before do
      @hf = Mutations::HashFilter.new do
        required do
          string :foo
        end
        optional do
          string :bar
        end
      end
    end
    
    it "bar is optional -- it works if not passed" do
      filtered, errors = @hf.filter(foo: "bar")
      assert_equal ({"foo" => "bar"}), filtered
      assert_equal nil, errors
    end
    
    it "bar is optional -- it works if nil is passed" do
      filtered, errors = @hf.filter(foo: "bar", bar: nil)
      assert_equal ({"foo" => "bar"}), filtered
      assert_equal nil, errors
    end
    
    it "bar is optional -- errors if nils not allowed" do
      hf = Mutations::HashFilter.new do
        required do
          string :foo
        end
        optional do
          string :bar, discard_nils: false
        end
      end
      
      filtered, errors = hf.filter(foo: "bar", bar: nil)
      assert_equal ({"bar" => :nils}), errors.symbolic
    end
    
    it "bar is optional -- discards empty" do
      hf = Mutations::HashFilter.new do
        required do
          string :foo
        end
        optional do
          string :bar, discard_empty: true
        end
      end
      
      filtered, errors = hf.filter(foo: "bar", bar: "")
      assert_equal ({"foo" => "bar"}), filtered
      assert_equal nil, errors
    end
    
    it "bar is optional -- errors if discard_empty is false and value is blank" do
      hf = Mutations::HashFilter.new do
        required do
          string :foo
        end
        optional do
          string :bar, discard_empty: false
        end
      end
      
      filtered, errors = hf.filter(foo: "bar", bar: "")
      assert_equal ({"bar" => :empty}), errors.symbolic
    end
    
    it "bar is optional -- discards empty -- now with wildcards" do
      hf = Mutations::HashFilter.new do
        required do
          string :foo
        end
        optional do
          string :*, discard_empty: true
        end
      end
      
      filtered, errors = hf.filter(foo: "bar", bar: "")
      assert_equal ({"foo" => "bar"}), filtered
      assert_equal nil, errors
    end
  end
  
  
end