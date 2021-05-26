Pod::Spec.new do |spec|

  spec.name         = "RewardzCommonComponents"
  spec.version      = "0.0.4"
  spec.summary      = "Common components"

  spec.description  = <<-DESC
Common components.
                   DESC

  spec.homepage     = "https://github.com/ankits1626/RewardzCommonComponents"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "Ankit Sachan" => "ankit@rewardz.sg" }

  spec.ios.deployment_target = "11.0"
  spec.swift_version = "4.2"

  spec.source        = { :git => "https://github.com/ankits1626/RewardzCommonComponents.git", :branch => "main", :tag => spec.version.to_s }
  spec.source_files  = "RewardzCommonComponents/**/*.{h,m,swift}"
spec.resources = "RewardzCommonComponents/**/*.{xib,png,jpg,jpeg }", "*.xcassets"
  spec.dependency 'KUIPopOver', '= 1.1.2'

end
