Pod::Spec.new do |s|

    s.name         = "SHEmotionKeyboard"
    s.version      = "0.0.1"
    s.summary      = "表情键盘"
    s.license      = 'MIT'
    s.authors      = {'CSH' => '624089195@qq.com'}
    s.platform     = :ios, '6.0'
    s.homepage     = 'https://github.com/CCSH/SHEmotionKeyboard'
    s.source       = {:git => 'https://github.com/CCSH/SHEmotionKeyboard.git', :tag => s.version}
    s.source_files = 'SHEmotionKeyboard/**/*.{h,m}'
    s.requires_arc = true
    s.resource     = 'SHEmotionKeyboard/SHEmotionKeyboard.bundle'
    s.dependency     'UIView+SHExtension','~> 0.0.1'
# s.framework  = "SomeFramework"
# s.frameworks = "SomeFramework", "AnotherFramework"
# s.library   = "iconv"
# s.libraries = "iconv", "xml2"

end
