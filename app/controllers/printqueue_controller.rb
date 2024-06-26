class PrintqueueController < ApplicationController
  def jobcount
    cmd = "lpstat"
    output = `#{cmd}` 
    a = output.split("\n") 
    count = a.count
    return count
  end
end