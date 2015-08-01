describe CategorySerializer do
  def serialized(params)
    @c = create :category, params
    CategorySerializer.new(@c).as_json
  end

  it 'should return the public API structure' do
    expect(serialized(name: 'Potato')).to eq({
      id: @c.id,
      title: 'Potato',
      name: 'potato'
    })

    expect(serialized(name: 'Salad Simulator')).to eq({
      id: @c.id,
      title: 'Salad Simulator',
      name: 'salad-simulator'
    })
  end
end
