require 'swt_shoes/spec_helper'

describe Shoes::Swt::FittedTextLayout do
  let(:layout) { double("layout", text: "the text", set_style: nil, bounds: bounds) }
  let(:bounds) { Java::OrgEclipseSwtGraphics::Rectangle.new(0, 0, 0, 0) }
  let(:element_left) { 0 }
  let(:element_top)  { 0 }

  let(:font_factory) { double("font factory", create_font: font, dispose: nil) }
  let(:style_factory) { double("style factory", create_style: style, dispose: nil) }
  let(:font)   { double("font") }
  let(:style)  { double("style") }

  let(:style_hash) {
    {
      bg: double("bg"),
      fg: double("fg"),
      font_detail: {
        name: "Comic Sans",
        size: 18,
        styles: nil
      }
    }
  }

  before(:each) do
    Shoes::Swt::TextFontFactory.stub(:new) { font_factory }
    Shoes::Swt::TextStyleFactory.stub(:new) { style_factory }
  end

  subject { Shoes::Swt::FittedTextLayout.new(layout, element_left, element_top) }

  context "setting style" do
    it "on full range" do
      subject.set_style(style_hash)
      expect(layout).to have_received(:set_style).with(style, 0, layout.text.length - 1)
    end

    it "with a range" do
      subject.set_style(style_hash, 1..2)
      expect(layout).to have_received(:set_style).with(style, 1, 2)
    end
  end

  context "bounds checking" do
    let(:layout_width)  { 10 }
    let(:layout_height) { 10 }
    let(:left_offset)   { 5 }
    let(:top_offset)    { 5 }

    before(:each) do
      set_bounds(0, 0, layout_width, layout_height)
    end

    it "checks boundaries" do
      expect(subject.in_bounds?(1,1)).to be_true
    end

    describe "offsets left" do
      let(:element_left) { left_offset }

      it "checks boundaries" do
        expect(subject.in_bounds?(layout_width + left_offset - 1, 0)).to be_true
      end
    end

    describe "offsets top" do
      let(:element_top) { top_offset }

      it "checks boundaries" do
        expect(subject.in_bounds?(0, layout_height + top_offset - 1)).to be_true
      end
    end

    def set_bounds(x, y, width, height)
      bounds.x = x
      bounds.y = y
      bounds.width = width
      bounds.height = height
    end
  end

  describe "dispose" do
    it "should dispose its Swt fonts" do
      subject.dispose
      expect(font_factory).to have_received(:dispose)
    end

    it "should dispose its Swt colors" do
      subject.dispose
      expect(style_factory).to have_received(:dispose)
    end
  end
end
