class Orchestrated::MessageDelivery
  # serialize to YAML
  def encode_with(coder)
    coder.map = super.merge "orchestration_id" => orchestration_id
  end
end
