SCHEME = FastGit Menu
BUILD_DIR = build
APP_NAME = FastGit Menu
DMG_NAME = FastGit-Menu

.PHONY: build archive dmg clean

build:
	xcodebuild \
		-scheme "$(SCHEME)" \
		-configuration Release \
		-derivedDataPath "$(BUILD_DIR)/derived" \
		build
	@mkdir -p "$(BUILD_DIR)"
	@cp -R "$(BUILD_DIR)/derived/Build/Products/Release/$(APP_NAME).app" "$(BUILD_DIR)/$(APP_NAME).app"
	@echo "Built: $(BUILD_DIR)/$(APP_NAME).app"

archive:
	xcodebuild \
		-scheme "$(SCHEME)" \
		-configuration Release \
		-archivePath "$(BUILD_DIR)/$(APP_NAME).xcarchive" \
		archive
	xcodebuild \
		-exportArchive \
		-archivePath "$(BUILD_DIR)/$(APP_NAME).xcarchive" \
		-exportOptionsPlist ExportOptions.plist \
		-exportPath "$(BUILD_DIR)/export"
	@echo "Archived: $(BUILD_DIR)/export/$(APP_NAME).app"

dmg: build
	@rm -f "$(BUILD_DIR)/$(DMG_NAME).dmg"
	hdiutil create \
		-volname "$(APP_NAME)" \
		-srcfolder "$(BUILD_DIR)/$(APP_NAME).app" \
		-ov \
		-format UDZO \
		"$(BUILD_DIR)/$(DMG_NAME).dmg"
	@echo "DMG: $(BUILD_DIR)/$(DMG_NAME).dmg"

clean:
	rm -rf "$(BUILD_DIR)"
	xcodebuild clean -scheme "$(SCHEME)" 2>/dev/null || true
