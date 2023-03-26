require "formula"

class Installer < Formula
  homepage "https://github.com/{{ .User }}/{{ .Program }}"
  version "{{ .Release }}"

  {{ range .Assets }}{{ if ne .Arch "arm" }}if {{if .IsMac }}!{{end}}OS.linux? && {{if .Is32Bit }}!{{end}}Hardware.is_64_bit?
    url "{{ .URL }}"
    {{if .SHA256 }}sha256 "{{ .SHA256 }}"{{end}}
  els{{end}}{{end}}e
    onoe "Not supported"
  end

  depends_on :arch => :intel

  def install
    bin.install '{{ .Program }}'
  end

  def caveats
    "{{ .Program }} was installed using https://github.com/ss-o/i"
  end
end
