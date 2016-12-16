
Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.name         = "FLFMDBManager"
  s.version      = "0.0.1"
  s.summary      = "FMDB 再封装，面向模型"
  s.description  = <<-DESC
			FMDB 再封装，面向模型，只需要传入模型或模型数组
                   DESC
  s.homepage     = "https://github.com/gitkong/FLFMDBManager"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.license      = "MIT (example)"
  s.license      = { :type => "MIT", :file => "FILE_LICENSE" }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.author             = { "gitKong" => "13751855378@163.com" }
 

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.platform     = :ios
  s.source       = { :git => "https://github.com/gitkong/FLFMDBManager.git", :tag => "#{s.version}" }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source_files  = "FLFMDBManagerDemo/FLFMDBManager/*.{h,m}"
  #s.exclude_files = "Classes/Exclude"
  #s.public_header_files = "FLFMDBManager/FLFMDBManager.h"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.requires_arc = true


end
