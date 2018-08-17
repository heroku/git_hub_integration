module WebmockHelpers
  def default_json_headers
    { "Content-Type" => "application/json" }
  end

  def stub_json_request(method, url, response_body, status = 200)
    stub_request(method, url)
      .to_return(status: status,
                 body: response_body,
                 headers: default_json_headers)
  end

  def stub_github_integration_request(body = nil)
    body ||= { token: "123" }.to_json
    url = "https://api.github.com/app/installations/1/access_tokens"
    stub_json_request(:post, url, body)
  end
end
