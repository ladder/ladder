object @search
cache @search

node :results do |search|
  search.results.map do |result|
    h = result.to_normalized_hash(@opts)
    h[:_id] = result.id
    h[:_score] = result._score
    h[:_explanation] = result._explanation if @search.explain
    h[:_type] = result._type
    h
  end
end

node :locales do
  @search.locales
end

node :facets do
  @search.results.facets
end

node :time do
  @search.results.time
end

node :total do
  @search.results.total
end