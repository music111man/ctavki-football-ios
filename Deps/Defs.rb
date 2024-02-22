##########
# project defs
##########
def project_app_path
    project "../App/App.xcodeproj"
end

def project_core_path(name)
    project "../Core/#{name}/#{name}"
end

def project_feature_path(name)
    project "../Feature/#{name}/#{name}"
end

def project_lib_path(name)
    project "../Lib/#{name}/#{name}"
end

##########
# pods defs
##########
def swiftlint 
    pod 'SwiftLint'
end

#def fastEasyMapping
#    pod 'FastEasyMapping', "~> 1.0"
#end

def swinject
    pod 'Swinject', '~> 2.5.0'
end

def rswift
    pod 'R.swift', '~> 5.0'
end

def rxSwift
    pod 'RxSwift', '~> 6.5.0'
end

def rxFeedback
    pod 'RxFeedback', '~> 4.0'
end

def rxCocoa
    pod 'RxCocoa', '~> 6.5.0'
end

def rxTest 
    pod 'RxTest', '~> 6.5.0'
end

def nimble
    pod 'Nimble', '~> 10.0.0'
end

def quick
    pod 'Quick', '~> 5.0.1'
end

def rxBlocking
    pod 'RxBlocking', '~> 6.5.0'
end

def coordinator
    pod 'VBCoordinator', '~> 1.0' 
end

def swiftDate
    pod 'SwiftDate', '~> 5.0'
end

def firebase
    pod 'Firebase/Crashlytics', '~> 8.1'
    pod 'Firebase/Analytics', '~> 8.1'
    pod 'Firebase/Messaging', '~> 8.1'
end