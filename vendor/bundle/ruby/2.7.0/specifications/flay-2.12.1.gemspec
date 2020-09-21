# -*- encoding: utf-8 -*-
# stub: flay 2.12.1 ruby lib

Gem::Specification.new do |s|
  s.name = "flay".freeze
  s.version = "2.12.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Ryan Davis".freeze]
  s.cert_chain = ["-----BEGIN CERTIFICATE-----\nMIIDPjCCAiagAwIBAgIBAzANBgkqhkiG9w0BAQsFADBFMRMwEQYDVQQDDApyeWFu\nZC1ydWJ5MRkwFwYKCZImiZPyLGQBGRYJemVuc3BpZGVyMRMwEQYKCZImiZPyLGQB\nGRYDY29tMB4XDTE4MTIwNDIxMzAxNFoXDTE5MTIwNDIxMzAxNFowRTETMBEGA1UE\nAwwKcnlhbmQtcnVieTEZMBcGCgmSJomT8ixkARkWCXplbnNwaWRlcjETMBEGCgmS\nJomT8ixkARkWA2NvbTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALda\nb9DCgK+627gPJkB6XfjZ1itoOQvpqH1EXScSaba9/S2VF22VYQbXU1xQXL/WzCkx\ntaCPaLmfYIaFcHHCSY4hYDJijRQkLxPeB3xbOfzfLoBDbjvx5JxgJxUjmGa7xhcT\noOvjtt5P8+GSK9zLzxQP0gVLS/D0FmoE44XuDr3iQkVS2ujU5zZL84mMNqNB1znh\nGiadM9GHRaDiaxuX0cIUBj19T01mVE2iymf9I6bEsiayK/n6QujtyCbTWsAS9Rqt\nqhtV7HJxNKuPj/JFH0D2cswvzznE/a5FOYO68g+YCuFi5L8wZuuM8zzdwjrWHqSV\ngBEfoTEGr7Zii72cx+sCAwEAAaM5MDcwCQYDVR0TBAIwADALBgNVHQ8EBAMCBLAw\nHQYDVR0OBBYEFEfFe9md/r/tj/Wmwpy+MI8d9k/hMA0GCSqGSIb3DQEBCwUAA4IB\nAQCbJwLmpJR2PomLU+Zzw3KRzH/hbyUWc/ftru71AopZ1fy4iY9J/BW5QYKVYwbP\nV0FSBWtvfI/RdwfKGtuGhPKECZgmLieGuZ3XCc09qPu1bdg7i/tu1p0t0c6163ku\nnDMDIC/t/DAFK0TY9I3HswuyZGbLW7rgF0DmiuZdN/RPhHq2pOLMLXJmFclCb/im\n9yToml/06TJdUJ5p64mkBs0TzaK66DIB1Smd3PdtfZqoRV+EwaXMdx0Hb3zdR1JR\nEm82dBUFsipwMLCYj39kcyHWAxyl6Ae1Cn9r/ItVBCxoeFdrHjfavnrIEoXUt4bU\nUfBugfLD19bu3nvL+zTAGx/U\n-----END CERTIFICATE-----\n".freeze]
  s.date = "2019-10-09"
  s.description = "Flay analyzes code for structural similarities. Differences in literal\nvalues, variable, class, method names, whitespace, programming style,\nbraces vs do/end, etc are all ignored. Making this totally rad.".freeze
  s.email = ["ryand-ruby@zenspider.com".freeze]
  s.executables = ["flay".freeze]
  s.extra_rdoc_files = ["History.rdoc".freeze, "Manifest.txt".freeze, "README.rdoc".freeze]
  s.files = ["History.rdoc".freeze, "Manifest.txt".freeze, "README.rdoc".freeze, "bin/flay".freeze]
  s.homepage = "http://ruby.sadi.st/".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--main".freeze, "README.rdoc".freeze]
  s.rubygems_version = "3.1.4".freeze
  s.summary = "Flay analyzes code for structural similarities".freeze

  s.installed_by_version = "3.1.4" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<sexp_processor>.freeze, ["~> 4.0"])
    s.add_runtime_dependency(%q<ruby_parser>.freeze, ["~> 3.0"])
    s.add_runtime_dependency(%q<erubis>.freeze, ["~> 2.7.0"])
    s.add_runtime_dependency(%q<path_expander>.freeze, ["~> 1.0"])
    s.add_development_dependency(%q<minitest>.freeze, ["~> 5.8.0"])
    s.add_development_dependency(%q<ruby2ruby>.freeze, ["~> 2.2.0"])
    s.add_development_dependency(%q<rdoc>.freeze, [">= 4.0", "< 7"])
    s.add_development_dependency(%q<hoe>.freeze, ["~> 3.18"])
  else
    s.add_dependency(%q<sexp_processor>.freeze, ["~> 4.0"])
    s.add_dependency(%q<ruby_parser>.freeze, ["~> 3.0"])
    s.add_dependency(%q<erubis>.freeze, ["~> 2.7.0"])
    s.add_dependency(%q<path_expander>.freeze, ["~> 1.0"])
    s.add_dependency(%q<minitest>.freeze, ["~> 5.8.0"])
    s.add_dependency(%q<ruby2ruby>.freeze, ["~> 2.2.0"])
    s.add_dependency(%q<rdoc>.freeze, [">= 4.0", "< 7"])
    s.add_dependency(%q<hoe>.freeze, ["~> 3.18"])
  end
end
