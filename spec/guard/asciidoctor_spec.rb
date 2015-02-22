require 'guard/compat/test/helper'

require 'guard/asciidoctor'

RSpec.describe Guard::Asciidoctor do
  let(:subject_with_options) { described_class.new(notifications: false, run_at_start: true) }
  let(:subject_notifiable) { described_class.new(notifications: true) }
  let(:subject_with_helper) { described_class.new(helper_modules: [TestingHelper]) }
  let(:notifier) { Guard::Asciidoctor::Notifier }

  before do
    allow(Guard::Compat::UI).to receive(:info)
  end

  describe 'class' do
    it 'should autoload Notifier class' do
      expect { Guard::Asciidoctor::Notifier }.not_to raise_error
    end
  end

  describe '#new' do
    context 'notifications option by default' do
      specify { expect(subject.options[:notifications]).to be_truthy }
    end

    context 'when receives options hash' do
      it 'should merge it to @options instance variable' do
        expect(subject_with_options.options[:notifications]).to be_falsey
        expect(subject_with_options.options[:run_at_start]).to be_truthy
      end
    end
  end

  describe '#start' do
    context 'by default' do
      it 'should not call #run_all' do
        expect(subject).not_to receive(:run_all)
        subject.start
      end
    end

    context 'when run_on_start option set to true' do
      it 'should call #run_all' do
        expect(subject_with_options).to receive(:run_all)
        subject_with_options.start
      end
    end

    context 'when run_on_start option set to false' do
      before do
        subject.options[:run_at_start] = false
      end

      it 'should not call #run_all' do
        expect(subject).not_to receive(:run_all)
        subject.start
      end
    end
  end

  describe '#stop' do
    specify { expect(subject.stop).to be_truthy }
  end

  describe '#reload' do
    it 'should call #run_all' do
      expect(subject).to receive(:run_all).and_return(true)
      subject.reload
    end
  end

  describe '#run_all' do
    it 'should rebuild all files being watched' do
      expect(Guard::Compat).to receive(:matching_files).and_return([])
      allow(subject).to receive(:run_on_changes).with([]).and_return([])
      subject.run_all
    end
  end

  describe '#_output_paths' do
    context 'by default' do
      it 'should return test/test/test.asciidoctor as [test/test/index.html]' do
        expect(subject.send(:_output_paths, 'test/test/index.adoc')).to eq(['test/test/index.html'])
      end

      it 'should return test/test.sciidoctor as [test/index.htm]' do
        expect(subject.send(:_output_paths, 'test/index.asciidoc')).to eq(['test/index.html'])
      end

      it 'should return test/test.adoc as [test/index.html]' do
        expect(subject.send(:_output_paths, 'test/index.adoc'))
          .to eq(['test/index.html'])
      end
    end

    context 'when the output option is set to "demo/output"' do
      before do
        subject.options[:output] = 'demo/output'
      end

      it 'should return test/test.asciidoctor as [demo/output/test/index.html.Asciidoctor]' do
        expect(subject.send(:_output_paths, 'test/index.adoc'))
          .to eq(['demo/output/test/index.html'])
      end
    end

    context 'when the output option is set to ["demo/output", "demo2/output"]' do
      before do
        subject.options[:output] = ['demo1/output', 'demo2/output']
      end

      it 'should return test/test.asciidoc as [demo1/output/test/index.html, demo2/output/test/index.html]' do
        expect(subject.send(:_output_paths, 'test/index.adoc'))
          .to eq(['demo1/output/test/index.html', 'demo2/output/test/index.html'])
      end
    end

    # context 'when the default extensions is set to "txt"' do
    #   before do
    #     subject.options[:default_ext] = 'txt'
    #   end
    #
    #   it 'should return test/test.asciidoc as test/index.txt' do
    #     expect(subject.send(:_output_paths, 'test/index.asciidoc'))
    #       .to eq(['test/index.txt'])
    #   end
    #
    #   it 'should return test/test.adoc as test/index.txt' do
    #     expect(subject.send(:_output_paths, 'test/index.adoc'))
    #       .to eq(['test/index.txt'])
    #   end
    # end

    context 'when the exclude_base_dir option is set to "test/ignore"' do
      before do
        subject.options[:input] = 'test/ignore'
      end

      it 'should return test/ignore/test.asciidoctor as [index.html]' do
        expect(subject.send(:_output_paths, 'test/ignore/index.adoc'))
          .to eq(['index.html'])
      end

      context 'when the output option is set to "demo/output"' do
        before do
          subject.options[:output] = 'demo/output'
        end

        it 'should return test/ignore/abc/test.asciidoc as [demo/output/abc/index.html]' do
          expect(subject.send(:_output_paths, 'test/ignore/abc/index.asciidoc'))
            .to eq(['demo/output/abc/index.html'])
        end
      end
    end

    # context 'when the input file contains a second extension"' do
    #   it 'should return test/test.asciidoctor as [test/index.php]' do
    #     expect(subject.send(:_output_paths, 'test/index.php.Asciidoctor'))
    #       .to eq(['test/index.php'])
    #   end
    # end
  end

  # describe '#_output_filename' do
  #   context 'by default (if a ".Asciidoctor" extension has been defined)' do
  #     it 'should return the file name with the default extension ".html"' do
  #      # expect(subject.send(:_output_filename, 'test/index.Asciidoctor'))
  #       #  .to eq('index.html')
  #     end
  #   end
  #
  #   context 'if no extension has been defined at all' do
  #     it 'should return the file name with the default extension ".html"' do
  #      # expect(subject.send(:_output_filename, 'test/index'))
  #      #   .to eq('index.html')
  #     end
  #   end
  #
  #   context 'if an extension other than ".Asciidoctor" has been defined' do
  #     it 'should return the file name with the default extension ".html"' do
  #      # expect(subject.send(:_output_filename, 'test/index.foo'))
  #      #   .to eq('index.foo.html')
  #     end
  #   end
  #
  #   context 'if multiple extensions including ".Asciidoctor" have been defined' do
  #     it 'should return the file name with the extension second to last' do
  #      # expect(subject.send(:_output_filename, 'test/index.foo.Asciidoctor'))
  #      #   .to eq('index.foo')
  #     end
  #   end
  # end

  describe '#run_on_changes' do
    context 'when notifications option set to true' do
      let(:success_message) { "Successfully compiled asciidoc!\n" }

      context 'with one output' do
        after do
           File.unlink "#{@fixture_path}/test.html"
        end

        # it 'should call Notifier.notify with 1 output' do
        #   message = success_message + '# spec/fixtures/test.asciidoc -> spec/fixtures/test.html'
        #   allow(Guard::Compat::UI).to receive(:info)
        #   expect(notifier).to receive(:notify).with(true, message)
        #   subject_notifiable.run_on_changes(["#{@fixture_path}/test.html"])
        # end
      end

      it 'should call Notifier.notify' do
         message = "Successfully compiled asciidoc!\n"
         message += '# spec/fixtures/test.asciidoc -> spec/fixtures/test.html'
         expect(notifier).to receive(:notify).with(true, message)
         subject_notifiable.run_on_changes(["#{@fixture_path}/test.asciidoc"])
      end

      context 'with two outputs' do
        before do
          allow(subject_notifiable).to receive(:_output_paths).and_return(["#{@fixture_path}/test.html", "#{@fixture_path}/test2.html"])
        end

        after do
          File.unlink "#{@fixture_path}/test.html"
          File.unlink "#{@fixture_path}/test2.html"
        end

        it 'should call Notifier.notify with 2 outputs' do
           message = success_message + '# spec/fixtures/test.asciidoc -> spec/fixtures/test.html, spec/fixtures/test2.html'
           allow(Guard::Compat::UI).to receive(:info)
           expect(notifier).to receive(:notify).with(true, message)
           subject_notifiable.run_on_changes(["#{@fixture_path}/test.asciidoc"])
        end
      end

      context 'with helper' do
        before do
          module TestingHelper
            def output_from_helper; 'generated by helper'; end
          end
        end

        after do
          File.unlink "#{@fixture_path}/test3.html"
          Object.send :remove_const, :TestingHelper
        end

        it 'should call Notifier.notify with 1 output' do
          message = success_message + '# spec/fixtures/test3.asciidoc -> spec/fixtures/test3.html'
          allow(Guard::Compat::UI).to receive(:error)
          allow(Guard::Compat::UI).to receive(:info)
          expect(notifier).to receive(:notify).with(true, message)
          subject_with_helper.run_on_changes(["#{@fixture_path}/test3.asciidoc"])
          expect(File.new("#{@fixture_path}/test3.html").read).to match(/generated by helper/)
        end
      end
    end
  end

  describe '#compile_Asciidoctor' do
    it 'throws :task_has_failed when an error occurs' do
      allow(Guard::Compat::UI).to receive(:error)
      allow(Guard::Compat::UI).to receive(:notify)
      expect { subject.send(:compile_asciidoc, "#{@fixture_path}/fail_test.asciidoc") }
       .to throw_symbol :task_has_failed
    end

    # context 'when notifications option set to true' do
    #   it 'should call Notifier.notify when an error occurs' do
    #     message = "Asciidoctor compilation of #{@fixture_path}/fail_test.asciidoctor failed!\n"
    #     message += "Error: Illegal nesting: content can't be both given on the same line as %p and nested within it."
    #     expect(notifier).to receive(:notify).with(false, message)
    #     allow(Guard::Compat::UI).to receive(:error)
    #     expect(catch(:task_has_failed) do
    #       subject_notifiable.send(:compile_Asciidoctor, "#{@fixture_path}/fail_test.asciidoctor")
    #     end.to be_nil
    #   end
    # end
  end
end
