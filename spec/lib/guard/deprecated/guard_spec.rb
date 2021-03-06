require "guard/config"

unless Guard::Config.new.strict?

  # require guard, to avoid circular require
  require "guard"
  # require "guard/deprecated/guard"

  require "guard/config"

  RSpec.describe Guard::Deprecated::Guard do
    let(:session) { instance_double("Guard::Internals::Session") }
    let(:state) { instance_double("Guard::Internals::State") }

    subject do
      module TestModule
        def self.plugins(_filter)
        end

        def self.add_plugin(*_args)
        end

        def self._pluginless_guardfile?
          false
        end
      end
      TestModule.tap { |mod| described_class.add_deprecated(mod) }
    end

    before do
      allow(Guard::UI).to receive(:deprecation)
      allow(session).to receive(:evaluator_options).and_return({})
      allow(state).to receive(:session).and_return(session)
      allow(Guard).to receive(:state).and_return(state)
    end

    describe ".guards" do
      before { allow(subject).to receive(:plugins) }

      it "displays a deprecation warning to the user" do
        expect(Guard::UI).to receive(:deprecation).
          with(Guard::Deprecated::Guard::ClassMethods::GUARDS)

        subject.guards
      end

      it "delegates to Guard.plugins" do
        expect(subject).to receive(:plugins).with(group: "backend")

        subject.guards(group: "backend")
      end
    end

    describe ".add_guard" do
      before { allow(subject).to receive(:add_plugin) }

      it "displays a deprecation warning to the user" do
        expect(Guard::UI).to receive(:deprecation).
          with(Guard::Deprecated::Guard::ClassMethods::ADD_GUARD)

        subject.add_guard("rspec")
      end

      it "delegates to Guard.plugins" do
        expect(subject).to receive(:add_plugin).with("rspec", group: "backend")

        subject.add_guard("rspec", group: "backend")
      end
    end

    describe ".get_guard_class" do
      let(:plugin_util) do
        instance_double("Guard::PluginUtil", plugin_class: true)
      end

      before do
        allow(Guard::PluginUtil).to receive(:new).with("rspec").
          and_return(plugin_util)
      end

      it "displays a deprecation warning to the user" do
        expect(Guard::UI).to receive(:deprecation).
          with(Guard::Deprecated::Guard::ClassMethods::GET_GUARD_CLASS)
        subject.get_guard_class("rspec")
      end

      it "delegates to Guard::PluginUtil" do
        expect(plugin_util).to receive(:plugin_class).
          with(fail_gracefully: false)
        subject.get_guard_class("rspec")
      end

      describe ":fail_gracefully" do
        it "pass it to get_guard_class" do
          expect(plugin_util).to receive(:plugin_class).
            with(fail_gracefully: true)
          subject.get_guard_class("rspec", true)
        end
      end
    end

    describe ".locate_guard" do
      let(:plugin_util) do
        instance_double("Guard::PluginUtil", plugin_location: true)
      end

      before do
        allow(Guard::PluginUtil).to receive(:new) { plugin_util }
      end

      it "displays a deprecation warning to the user" do
        expect(Guard::UI).to receive(:deprecation).
          with(Guard::Deprecated::Guard::ClassMethods::LOCATE_GUARD)

        subject.locate_guard("rspec")
      end

      it "delegates to Guard::PluginUtil" do
        expect(Guard::PluginUtil).to receive(:new).with("rspec") { plugin_util }
        expect(plugin_util).to receive(:plugin_location)

        subject.locate_guard("rspec")
      end
    end

    describe ".guard_gem_names" do
      before { allow(Guard::PluginUtil).to receive(:plugin_names) }

      it "displays a deprecation warning to the user" do
        expect(Guard::UI).to receive(:deprecation).
          with(Guard::Deprecated::Guard::ClassMethods::GUARD_GEM_NAMES)

        subject.guard_gem_names
      end

      it "delegates to Guard::PluginUtil" do
        expect(Guard::PluginUtil).to receive(:plugin_names)

        subject.guard_gem_names
      end
    end

    describe ".running" do
      it "show deprecation warning" do
        expect(Guard::UI).to receive(:deprecation).
          with(Guard::Deprecated::Guard::ClassMethods::RUNNING)

        subject.running
      end
    end

    describe ".lock" do
      it "show deprecation warning" do
        expect(Guard::UI).to receive(:deprecation).
          with(Guard::Deprecated::Guard::ClassMethods::LOCK)

        subject.lock
      end
    end

    describe "reset_evaluator" do
      it "show deprecation warning" do
        expect(Guard::UI).to receive(:deprecation).
          with(Guard::Deprecated::Guard::ClassMethods::RESET_EVALUATOR)
        subject.reset_evaluator({})
      end
    end

    describe "evaluator" do
      before do
        allow(Guard::Guardfile::Evaluator).to receive(:new).
          and_return(double("evaluator"))
      end
      it "show deprecation warning" do
        expect(Guard::UI).to receive(:deprecation).
          with(Guard::Deprecated::Guard::ClassMethods::EVALUATOR)
        subject.evaluator
      end
    end

    describe "evaluate_guardfile" do
      let(:evaluator) { instance_double("Guard::Guardfile::Evaluator") }

      before do
        allow(::Guard::Guardfile::Evaluator).to receive(:new).
          and_return(evaluator)
        allow(evaluator).to receive(:evaluate)
      end

      it "show deprecation warning" do
        expect(Guard::UI).to receive(:deprecation).
          with(Guard::Deprecated::Guard::ClassMethods::EVALUATOR)
        subject.evaluate_guardfile
      end

      it "evaluates the guardfile" do
        expect(evaluator).to receive(:evaluate)
        subject.evaluate_guardfile
      end
    end

    describe "options" do
      let(:options) { instance_double("Guard::Options") }

      before do
        allow(session).to receive(:options).and_return(options)
      end

      it "show deprecation warning" do
        expect(Guard::UI).to receive(:deprecation).
          with(Guard::Deprecated::Guard::ClassMethods::OPTIONS)
        subject.options
      end

      it "provides an alternative implementation" do
        expect(session).to receive(:options).and_return(options)
        expect(subject.options).to be(options)
      end
    end
  end
end
