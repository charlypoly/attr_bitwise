require_relative '../lib/attr_bitwise.rb'

describe AttrBitwise do

  # test class in order to test concern
  class TestClass

    include AttrBitwise

    attr_accessor :payment_types_value

    attr_bitwise :payment_types, mapping: [:slots, :credits]

    def initialize
      @payment_types_value = 0
    end

  end

  subject { TestClass.new }

  context '.to_bitwise_values' do

    context 'with Hash argument' do
      it do
        expect(
          TestClass.to_bitwise_values(
            {
              a: :credits,
              b: :slots
            },
            'payment_types'
          )
        ).to eq [2, 1]
      end
    end

    context 'with Array argument' do
      it do
        expect(TestClass.to_bitwise_values(
          [:credits, :slots],
          'payment_types'
        )).to eq [2, 1]
      end
    end

    context 'with Fixnum argument' do
      it do
        expect(TestClass.to_bitwise_values(1, 'payment_types')).to eq 1
      end
    end

  end

  context 'with `payment_types` attribute_name' do

    context '#payment_types=' do

      before { subject.payment_types = [:slots, :credits] }

      it 'should set proper value' do
        expect(subject.payment_types_value).to eq 3
        expect(subject.payment_types).to eq [:slots, :credits]
      end

    end

    context 'with `payment_types_value` = 0' do
      context '#payment_types' do

        it do
          expect(subject.payment_types).to eq []
        end

      end

      context '#add_payment_type' do

        it do
          subject.add_payment_type(:slots)
          expect(subject.payment_types).to eq [:slots]
        end

        context 'when called twice, each type remains unique' do
          it do
            subject.add_payment_type(:slots)
            subject.add_payment_type(:slots)
            expect(subject.payment_types).to eq [:slots]
          end
        end

      end

      context '#payment_type?(:slots)' do

        it do
          expect(subject.payment_type?(:slots)).to eq false
        end

      end
    end

    context 'with `payment_types_value` = 3' do

      before { subject.payment_types_value = 3 }

      context '#payment_types' do

        it do
          expect(subject.payment_types).to eq [:slots, :credits]
        end

      end

      context '#payment_type?(:slots)' do

        it do
          expect(subject.payment_type?(:slots)).to eq true
        end

      end

      context '#remove_payment_type' do

        it do
          subject.remove_payment_type(:slots)
          expect(subject.payment_types).to eq [:credits]
        end

      end

      context '#payment_types_union' do

        it do
          expect(subject.payment_types_union(1, 2)).to eq [1, 3, 2]
        end

      end

      context '.bitwise_union' do

        it do
          expect(
            TestClass.bitwise_union(1, 2, 'payment_types')
          ).to eq [1, 3, 2]
        end

      end

      context '#bitwise_intersection' do

        it do
          expect(
            TestClass.bitwise_intersection(1, 2, 'payment_types')
          ).to eq [3]
        end

      end

    end

  end
end
