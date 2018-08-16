#
#  Be sure to run `pod spec lint SHEmotionKeyboard.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

    s.name         = "SHEmotionKeyboard"
    s.version      = "0.0.1"
    s.summary      = "A short description of SHEmotionKeyboard."
    s.license      = 'MIT'
    s.authors      = {'CSH' => '624089195@qq.com'}
    s.platform     = :ios, '6.0'
    s.homepage     = 'https://github.com/CCSH/SHEmotionKeyboard'
    s.source       = {:git => 'https://github.com/CCSH/SHEmotionKeyboard.git', :tag => s.version}
    s.source_files = 'SHEmotionKeyboard/**/*.{h,m}'
    s.requires_arc = true
    s.resource     = 'SHEmotionKeyboard/SHEmotionKeyboard.bundle'
    s.dependency pod 'UIView+SHExtension'
# s.framework  = "SomeFramework"
# s.frameworks = "SomeFramework", "AnotherFramework"
# s.library   = "iconv"
# s.libraries = "iconv", "xml2"

end
