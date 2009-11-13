def try(x,&block)
  val = block.call
  if val.nil?
    if x == 0
      return nil
    else
      try(x-1) { block.call }
    end
  else
    return val
  end
end