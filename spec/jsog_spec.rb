
require 'jsog'

describe JSOG do
  context "#encode" do
    it "encodes an object graph with multiple references to the same object" do
      inner = { 'foo' => 'bar' }
      outer = { 'inner1' => inner, 'inner2' => inner }

      encoded = JSOG.encode(outer)

      inner1 = encoded['inner1']
      inner2 = encoded['inner2']

      # one has @id, one has @ref
      inner1.has_key?('@id').should_not == inner2.has_key?('@id')
      inner1.has_key?('@ref').should_not == inner2.has_key?('@ref')

      if inner1.has_key?('@id')
        inner1['@id'].should == inner2['@ref']
      else
        inner2['@id'].should == inner1['@ref']
      end
    end

    it "encodes an object graph with circular references" do
      thing = {}
      thing['me'] = thing

      encoded = JSOG.encode(thing)

      encoded['@id'].should == encoded['me']['@ref']
    end

    it "encodes an object graph with arrays that have objects in them" do
      thing = { "name" => "thing" }
      inner = { "name" => "inner" }
      thing["things"] = [inner]

      encoded = JSOG.encode(thing)
      encoded["things"].first["name"].should == "inner"
    end

    it "encodes nil as-is" do
      encoded = JSOG.encode(nil)
      encoded.should be_nil
    end
  end

  context "#decode" do

    it "decodes an object graph with multiple references to the same object" do
      #jsog = '{"@id":"1","foo":"foo","inner1":{"@id":"2","bar":"bar"},"inner2":{"@ref":"2"}}'

      jsog = { '@id'=>'1', 'inner1' => { '@id' => '2', 'bar' => 'bar' }, 'inner2' => { '@ref' => '2' } }

      decoded = JSOG.decode(jsog)
      inner1 = decoded['inner1']
      inner2 = decoded['inner2']

      inner1.should be(inner2)
    end

    it "decodes an object graph with circular references" do
      jsog = {"@id"=>"1", "me"=>{"@ref"=>"1"}}

      decoded = JSOG.decode(jsog)

      decoded.should be(decoded['me'])
    end

    it "decodes an object graph with arrays that have objects in them" do
      jsog = { "@id" => "1", "name" => "thing" }
      inner = { "@id" => "2", "name" => "inner" }
      jsog["things"] = [inner]

      decoded = JSOG.decode(jsog)
      decoded["things"].first["name"].should == "inner"
    end

    it "decodes nil as-is" do
      decoded = JSOG.decode(nil)
      decoded.should be_nil
    end

    it "decodes JSON normally" do
      json = { "foo" => "bar" }
      decoded = JSOG.decode(json)

      decoded.should == json
    end
  end
end
