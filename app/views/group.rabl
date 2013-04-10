cache @group

node do |g|
  if !! @opts[:all_keys]
    h = g.to_normalized_hash(@opts)
    h[:_id] = g.id
    h[:md5] = Digest.hexencode(g.md5.to_s)
  else
    h = {:_id => g.id, :md5 => Digest.hexencode(g.md5.to_s), :heading => g.heading, :type => g.type}
  end

  h
end