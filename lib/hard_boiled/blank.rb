class Array
  # Synonym for #empty?
  def blank?
    self.empty?
  end
end

class NilClass
  # Synonym for #nil?
  def blank?
    self.nil?
  end
end