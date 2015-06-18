class Guestlist < Array

  def find(id)
    self.each do |el|
      if el.id.eql?(id.to_s)
        return el
      end
    end
  end

  def scan
    self.each do |el|
      el.scan
    end
    self
  end

  def rescan
    scan
  end

end