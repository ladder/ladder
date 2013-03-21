collection @search.results.to_a, :root => :results, :object_root => false
cache @search.results.to_a

node do |m|
  h = m.to_normalized_hash(@opts)
  h[:_id] = m.id
  h[:_score] = m._score
  h[:_explanation] = m._explanation if @search.explain
  h[:_type] = m._type
  h
end