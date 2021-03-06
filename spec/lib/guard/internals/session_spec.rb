require "guard/internals/session"

RSpec.describe Guard::Internals::Session do
  let(:options) { {} }
  subject { described_class.new(options) }

  let(:plugins) { instance_double("Guard::Internals::Plugins") }
  let(:groups) { instance_double("Guard::Internals::Plugins") }

  before do
    allow(Guard::Internals::Plugins).to receive(:new).and_return(plugins)
    allow(Guard::Internals::Groups).to receive(:new).and_return(groups)
  end

  describe "#initialize" do

    describe "#listener_args" do
      subject { described_class.new(options).listener_args }

      context "with a single watchdir" do
        let(:options) { { watchdir: ["/usr"] } }
        let(:dir) { Gem.win_platform? ? "C:/usr" : "/usr" }
        it { is_expected.to eq [:to, dir, {}] }
      end

      context "with multiple watchdirs" do
        let(:options) { { watchdir: ["/usr", "/bin"] } }
        let(:dir1) { Gem.win_platform? ? "C:/usr" : "/usr" }
        let(:dir2) { Gem.win_platform? ? "C:/bin" : "/bin" }
        it { is_expected.to eq [:to, dir1, dir2, {}] }
      end

      context "with force_polling option" do
        let(:options) { { force_polling: true } }
        it { is_expected.to eq [:to, Dir.pwd, force_polling: true] }
      end

      context "with latency option" do
        let(:options) { { latency: 1.5 } }
        it { is_expected.to eq [:to, Dir.pwd, latency: 1.5] }
      end
    end

    context "with the plugin option" do
      let(:options) do
        {
          plugin:             %w(cucumber jasmine),
          guardfile_contents: "guard :jasmine do; end; "\
          "guard :cucumber do; end; guard :coffeescript do; end"
        }
      end

      let(:jasmine) { instance_double("Guard::Plugin") }
      let(:cucumber) {  instance_double("Guard::Plugin") }
      let(:coffeescript) { instance_double("Guard::Plugin") }

      before do
        stub_const "Guard::Jasmine", jasmine
        stub_const "Guard::Cucumber", cucumber
        stub_const "Guard::CoffeeScript", coffeescript
      end

      it "initializes the plugin scope" do
        allow(plugins).to receive(:add).with("cucumber", {}).
          and_return(cucumber)

        allow(plugins).to receive(:add).with("jasmine", {}).
          and_return(jasmine)

        expect(subject.cmdline_plugins).to match_array(%w(cucumber jasmine))
      end
    end

    context "with the group option" do
      let(:options) do
        {
          group: %w(backend frontend),
          guardfile_contents: "group :backend do; end; "\
          "group :frontend do; end; group :excluded do; end"
        }
      end

      before do
        g3 = instance_double("Guard::Group", name: :backend, options: {})
        g4 = instance_double("Guard::Group", name: :frontend, options: {})
        allow(Guard::Group).to receive(:new).with("backend", {}).and_return(g3)
        allow(Guard::Group).to receive(:new).with("frontend", {}).and_return(g4)
      end

      it "initializes the group scope" do
        expect(subject.cmdline_groups).to match_array(%w(backend frontend))
      end
    end
  end

  describe "#clearing" do
    context "when not set" do
      context "when clearing is not set from commandline" do
        it { is_expected.to_not be_clearing }
      end

      context "when clearing is set from commandline" do
        let(:options) { { clear: false } }
        it { is_expected.to_not be_clearing }
      end
    end

    context "when set from guardfile" do
      context "when set to :on" do
        before { subject.clearing(true) }
        it { is_expected.to be_clearing }
      end

      context "when set to :off" do
        before { subject.clearing(false) }
        it { is_expected.to_not be_clearing }
      end
    end
  end

  describe "#guardfile_ignore=" do
    context "when set from guardfile" do
      before { subject.guardfile_ignore = [/foo/] }
      specify { expect(subject.guardfile_ignore).to eq([/foo/]) }
    end

    context "when unset" do
      specify { expect(subject.guardfile_ignore).to eq([]) }
    end
  end

  describe "#guardfile_ignore_bang=" do
    context "when set from guardfile" do
      before { subject.guardfile_ignore_bang = [/foo/] }
      specify { expect(subject.guardfile_ignore_bang).to eq([/foo/]) }
    end

    context "when unset" do
      specify { expect(subject.guardfile_ignore_bang).to eq([]) }
    end
  end
end
