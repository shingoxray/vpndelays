#!/usr/bin/env python3
"""生成 VPNDelays.xcodeproj/project.pbxproj"""

import os, hashlib, json

PROJECT_DIR = os.path.dirname(os.path.abspath(__file__))
APP_DIR = os.path.join(PROJECT_DIR, "VPNDelays")

def uid(seed):
    """根据 seed 生成稳定的 24 位 hex UUID"""
    h = hashlib.md5(seed.encode()).hexdigest()
    return h[:24].upper()

# 所有源文件
SOURCE_FILES = [
    "VPNDelaysApp.swift",
    "AppDelegate.swift",
    "Models/VPNEndpoint.swift",
    "Models/TunnelStatus.swift",
    "Models/TunnelNamePreset.swift",
    "Utils/PingParser.swift",
    "ViewModels/DataStore.swift",
    "ViewModels/PingManager.swift",
    "Views/PopoverContentView.swift",
    "Views/EndpointRowView.swift",
    "Views/TunnelRowView.swift",
    "Views/AddEndpointView.swift",
    "Views/SettingsView.swift",
    "Views/MenuIconView.swift",
]

RESOURCE_FILES = [
    "Resources/Assets.xcassets",
]

INFO_PLIST = "Info.plist"

# ========== PBXBuildFile ==========
build_files = {}
for f in SOURCE_FILES:
    key = uid("build_" + f)
    ref = uid("ref_" + f)
    build_files[key] = {
        "isa": "PBXBuildFile",
        "fileRef": ref,
    }

# ========== PBXFileReference ==========
file_refs = {}
for f in SOURCE_FILES:
    key = uid("ref_" + f)
    file_refs[key] = {
        "isa": "PBXFileReference",
        "lastKnownFileType": "sourcecode.swift",
        "name": os.path.basename(f),
        "path": f,
        "sourceTree": "<group>",
    }

for f in RESOURCE_FILES:
    key = uid("ref_" + f)
    file_refs[key] = {
        "isa": "PBXFileReference",
        "lastKnownFileType": "folder.assetcatalog",
        "name": os.path.basename(f),
        "path": f,
        "sourceTree": "<group>",
    }

# Info.plist
plist_ref = uid("ref_Info.plist")
file_refs[plist_ref] = {
    "isa": "PBXFileReference",
    "lastKnownFileType": "text.plist.xml",
    "name": "Info.plist",
    "path": "Info.plist",
    "sourceTree": "<group>",
}

# ========== PBXGroup ==========
groups = {}

# 子分组
subgroups = {
    "Models": ["Models/VPNEndpoint.swift", "Models/TunnelStatus.swift", "Models/TunnelNamePreset.swift"],
    "Utils": ["Utils/PingParser.swift"],
    "ViewModels": ["ViewModels/DataStore.swift", "ViewModels/PingManager.swift"],
    "Views": ["Views/PopoverContentView.swift", "Views/EndpointRowView.swift",
               "Views/TunnelRowView.swift", "Views/AddEndpointView.swift",
               "Views/SettingsView.swift", "Views/MenuIconView.swift"],
    "Resources": ["Resources/Assets.xcassets"],
}

for gname, files in subgroups.items():
    gkey = uid("group_" + gname)
    children = []
    for f in files:
        children.append(uid("ref_" + f))
    groups[gkey] = {
        "isa": "PBXGroup",
        "children": children,
        "name": gname,
        "sourceTree": "<group>",
    }

# 主分组
main_group_key = uid("group_main")
root_files = ["VPNDelaysApp.swift", "AppDelegate.swift", "Info.plist"]
main_children = [uid("ref_" + f) for f in root_files]
main_children += [uid("group_" + gname) for gname in subgroups.keys()]
main_group = {
    "isa": "PBXGroup",
    "children": main_children,
    "sourceTree": "<group>",
}
# 用 name 还是 path？
# 对于顶层组使用 path=""
main_group["path"] = "VPNDelays"

# ========== PBXSourcesBuildPhase ==========
sources_phase_key = uid("sources_phase")
sources_phase = {
    "isa": "PBXSourcesBuildPhase",
    "buildActionMask": 2147483647,
    "files": [uid("build_" + f) for f in SOURCE_FILES],
    "runOnlyForDeploymentPostprocessing": 0,
}

# ========== PBXFrameworksBuildPhase ==========
frameworks_phase_key = uid("frameworks_phase")
frameworks_phase = {
    "isa": "PBXFrameworksBuildPhase",
    "buildActionMask": 2147483647,
    "files": [],
    "runOnlyForDeploymentPostprocessing": 0,
}

# ========== PBXResourcesBuildPhase ==========
resources_phase_key = uid("resources_phase")
resources_phase = {
    "isa": "PBXResourcesBuildPhase",
    "buildActionMask": 2147483647,
    "files": [],
    "runOnlyForDeploymentPostprocessing": 0,
}

# ========== PBXNativeTarget ==========
target_key = uid("target_main")
target = {
    "isa": "PBXNativeTarget",
    "buildConfigurationList": uid("target_build_config_list"),
    "buildPhases": [
        sources_phase_key,
        frameworks_phase_key,
        resources_phase_key,
    ],
    "buildRules": [],
    "dependencies": [],
    "name": "VPNDelays",
    "productName": "VPNDelays",
    "productReference": uid("product_ref"),
    "productType": "com.apple.product-type.application",
}

# ========== PBXFileReference for product ==========
file_refs[uid("product_ref")] = {
    "isa": "PBXFileReference",
    "explicitFileType": "wrapper.application",
    "includeInIndex": 0,
    "path": "VPNDelays.app",
    "sourceTree": "BUILT_PRODUCTS_DIR",
}

# ========== XCBuildConfiguration (Target) ==========
target_debug_key = uid("target_config_debug")
target_debug = {
    "isa": "XCBuildConfiguration",
    "buildSettings": {
        "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
        "COMBINE_HIDPI_IMAGES": "YES",
        "CURRENT_PROJECT_VERSION": "1",
        "GENERATE_INFOPLIST_FILE": "NO",
        "ENABLE_PREVIEWS": "NO",
        "INFOPLIST_FILE": "VPNDelays/Info.plist",
        "INFOPLIST_KEY_CFBundleDisplayName": "VPNDelays",
        "INFOPLIST_KEY_CFBundleIdentifier": "com.vpndelays.app",
        "INFOPLIST_KEY_LSMinimumSystemVersion": "12.0",
        "MACOSX_DEPLOYMENT_TARGET": "12.0",
        "PRODUCT_BUNDLE_IDENTIFIER": "com.vpndelays.app",
        "PRODUCT_NAME": "$(TARGET_NAME)",
        "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG",
        "SWIFT_VERSION": "5.0",
    },
    "name": "Debug",
}

target_release_key = uid("target_config_release")
target_release = {
    "isa": "XCBuildConfiguration",
    "buildSettings": {
        "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
        "COMBINE_HIDPI_IMAGES": "YES",
        "CURRENT_PROJECT_VERSION": "1",
        "ENABLE_PREVIEWS": "NO",
        "GENERATE_INFOPLIST_FILE": "NO",
        "INFOPLIST_FILE": "VPNDelays/Info.plist",
        "INFOPLIST_KEY_CFBundleDisplayName": "VPNDelays",
        "INFOPLIST_KEY_CFBundleIdentifier": "com.vpndelays.app",
        "INFOPLIST_KEY_LSMinimumSystemVersion": "12.0",
        "MACOSX_DEPLOYMENT_TARGET": "12.0",
        "PRODUCT_BUNDLE_IDENTIFIER": "com.vpndelays.app",
        "PRODUCT_NAME": "$(TARGET_NAME)",
        "SWIFT_VERSION": "5.0",
    },
    "name": "Release",
}

# ========== XCBuildConfiguration (Project) ==========
project_debug_key = uid("project_config_debug")
project_debug = {
    "isa": "XCBuildConfiguration",
    "buildSettings": {
        "ALWAYS_SEARCH_USER_PATHS": "NO",
        "CLANG_ANALYZER_NONNULL": "YES",
        "CLANG_CXX_LANGUAGE_STANDARD": "gnu++20",
        "CLANG_ENABLE_MODULES": "YES",
        "CLANG_ENABLE_OBJC_ARC": "YES",
        "COPY_PHASE_STRIP": "NO",
        "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
        "ENABLE_STRICT_OBJC_MSGSEND": "YES",
        "GCC_DYNAMIC_NO_PIC": "NO",
        "GCC_OPTIMIZATION_LEVEL": "0",
        "GCC_PREPROCESSOR_DEFINITIONS": "DEBUG=1",
        "MACOSX_DEPLOYMENT_TARGET": "12.0",
        "ONLY_ACTIVE_ARCH": "YES",
        "SDKROOT": "macosx",
        "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG",
        "SWIFT_OPTIMIZATION_LEVEL": "-Onone",
    },
    "name": "Debug",
}

project_release_key = uid("project_config_release")
project_release = {
    "isa": "XCBuildConfiguration",
    "buildSettings": {
        "ALWAYS_SEARCH_USER_PATHS": "NO",
        "CLANG_ANALYZER_NONNULL": "YES",
        "CLANG_CXX_LANGUAGE_STANDARD": "gnu++20",
        "CLANG_ENABLE_MODULES": "YES",
        "CLANG_ENABLE_OBJC_ARC": "YES",
        "COPY_PHASE_STRIP": "NO",
        "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
        "ENABLE_NS_ASSERTIONS": "NO",
        "ENABLE_STRICT_OBJC_MSGSEND": "YES",
        "GCC_OPTIMIZATION_LEVEL": "s",
        "MACOSX_DEPLOYMENT_TARGET": "12.0",
        "SDKROOT": "macosx",
        "SWIFT_COMPILATION_MODE": "wholemodule",
        "SWIFT_OPTIMIZATION_LEVEL": "-O",
        "VALIDATE_PRODUCT": "YES",
    },
    "name": "Release",
}

# ========== XCConfigurationList ==========
target_config_list_key = uid("target_build_config_list")
target_config_list = {
    "isa": "XCConfigurationList",
    "buildConfigurations": [target_debug_key, target_release_key],
    "defaultConfigurationIsVisible": 0,
    "defaultConfigurationName": "Debug",
}

project_config_list_key = uid("project_build_config_list")
project_config_list = {
    "isa": "XCConfigurationList",
    "buildConfigurations": [project_debug_key, project_release_key],
    "defaultConfigurationIsVisible": 0,
    "defaultConfigurationName": "Debug",
}

# ========== PBXProject ==========
project_key = uid("project")
project = {
    "isa": "PBXProject",
    "attributes": {
        "LastSwiftUpdateCheck": "1500",
        "LastUpgradeCheck": "1500",
        "TargetAttributes": {
            target_key: {
                "CreatedOnToolsVersion": "15.0",
            }
        }
    },
    "buildConfigurationList": project_config_list_key,
    "compatibilityVersion": "Xcode 13.0",
    "developmentRegion": "en",
    "hasScannedForEncodings": 0,
    "knownRegions": ["en", "Base", "zh-Hans"],
    "mainGroup": main_group_key,
    "productRefGroup": main_group_key,
    "projectDirPath": "",
    "projectRoot": "",
    "targets": [target_key],
}

# ========== 组装 ==========
objects = {}
objects.update(build_files)
objects.update(file_refs)
objects.update(groups)
objects[main_group_key] = main_group
objects[sources_phase_key] = sources_phase
objects[frameworks_phase_key] = frameworks_phase
objects[resources_phase_key] = resources_phase
objects[target_key] = target
objects[target_debug_key] = target_debug
objects[target_release_key] = target_release
objects[project_debug_key] = project_debug
objects[project_release_key] = project_release
objects[target_config_list_key] = target_config_list
objects[project_config_list_key] = project_config_list
objects[project_key] = project

# ========== 写入 ==========
xcodeproj_dir = os.path.join(PROJECT_DIR, "VPNDelays.xcodeproj")
os.makedirs(xcodeproj_dir, exist_ok=True)

def write_pbxstring(f, value, indent=0):
    """将值写成 ASCII plist 格式"""
    pad = "\t" * indent
    if isinstance(value, bool):
        f.write(f"{pad}{str(value).lower()}\n")
    elif isinstance(value, int):
        f.write(f"{pad}{value}\n")
    elif isinstance(value, str):
        escaped = value.replace('"', '\\"').replace('\n', '\\n')
        f.write(f'{pad}"{escaped}"\n')
    elif isinstance(value, dict):
        f.write(f"{pad}{{\n")
        for k, v in value.items():
            f.write(f"{pad}\t{k} = ")
            write_pbxstring(f, v, indent + 1)
            f.write(";\n")
        f.write(f"{pad}}}\n")
    elif isinstance(value, list):
        f.write(f"{pad}(\n")
        for item in value:
            write_pbxstring(f, item, indent + 1)
            f.write(",\n")
        f.write(f"{pad})\n")

with open(os.path.join(xcodeproj_dir, "project.pbxproj"), "w") as f:
    f.write("// !$*UTF8*$!\n")
    f.write("{\n")
    f.write("\tarchiveVersion = 1;\n")
    f.write("\tclasses = {\n")
    f.write("\t};\n")
    f.write("\tobjectVersion = 56;\n")
    f.write("\tobjects = {\n")

    # 分组写出：按 isa 排序
    isa_order = [
        "PBXBuildFile", "PBXFileReference", "PBXFrameworksBuildPhase",
        "PBXGroup", "PBXNativeTarget", "PBXProject",
        "PBXResourcesBuildPhase", "PBXSourcesBuildPhase",
        "XCBuildConfiguration", "XCConfigurationList",
    ]

    written = set()
    for isa in isa_order:
        items = {k: v for k, v in objects.items() if v.get("isa") == isa}
        for key, obj in items.items():
            f.write(f"\n/* Begin {isa} section */\n")
            f.write(f"\t\t{key} /* {'_'.join(obj.get('name', obj.get('path', key)).split('/'))} */ = {{\n")
            # 按 key 排序写出，isa 放第一位
            sorted_keys = sorted(obj.keys())
            if "isa" in sorted_keys:
                sorted_keys.remove("isa")
                sorted_keys.insert(0, "isa")
            for k in sorted_keys:
                v = obj[k]
                f.write(f"\t\t\t{k} = ")
                write_pbxstring(f, v, 3)
                f.write(";\n")
            f.write(f"\t\t}};\n")
            f.write(f"/* End {isa} section */\n")
            written.add(key)

    f.write("\t};\n")
    f.write(f"\trootObject = {project_key};\n")
    f.write("}\n")

print(f"✅ Xcode 项目已创建: {xcodeproj_dir}")
