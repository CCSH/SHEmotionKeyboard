Pod::Spec.new do |s|
    s.name         = "SHEmotionKeyboard"
    s.version      = "1.1.0"
    s.summary      = "表情键盘"
    s.license      = "MIT"
    s.authors      = { "CSH" => "624089195@qq.com" }
    s.platform     = :ios, "7.0"
    s.homepage     = "https://github.com/CCSH/SHEmotionKeyboard"
    s.source       = { :git => "https://github.com/CCSH/SHEmotionKeyboard.git", :tag => s.version }
    s.source_files = "SHEmotionKeyboard/*.{h,m}"
    s.resource     = "SHEmotionKeyboard/SHEmotionKeyboard.bundle"
    s.requires_arc = true
    s.dependency    "SHExtension/UIView"
end
