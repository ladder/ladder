cache @groups

node :groups do
  @groups.map do |group|
    if !! @opts[:all_keys]
      h = group.to_normalized_hash(@opts)
      h[:_id] = group.id
      h[:md5] = Digest.hexencode(group.md5.to_s)
    else
      h = {:_id => group.id, :md5 => Digest.hexencode(group.md5.to_s), :heading => group.heading, :type => group.type}
    end
    h
  end
end

node :total do
  @groups.size
end
