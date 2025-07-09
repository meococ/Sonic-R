# APEX Pullback EA v4.0

## 🚀 Quick Start - Compile System

```powershell
# Quick compile EA
.\compile.ps1 -Quick

# Compile specific file  
.\compile.ps1 -Target Core_Settings

# Compile all files (overview)
.\compile.ps1 -Target all -Silent

# Show help
.\compile.ps1 -Help
```

## 📊 Current Status

- **Files:** 9 total (.mq5, .mqh)
- **Compilation:** ❌ Failed (516 errors, 102 warnings)
- **Architecture:** ✅ Ready (organized, modular)

## 📂 Structure

```
APEX_PULLBACK_EA_v4/
├── compile.ps1                # 🎯 Main compilation interface
├── Compile/                   # 📁 Compilation scripts
├── Core_*.mqh                 # 🏗️ Core infrastructure modules  
├── Analysis_*.mqh             # 📈 Market analysis modules
├── Signal_*.mqh               # 🎯 Trading signal modules
└── APEX_Pullback_EA_v4.mq5    # 🚀 Main EA file
```

## 🔧 Next Steps

1. Fix core compilation errors (pointer access issues)
2. Test individual modules  
3. Complete Phase 1 refactoring
4. Implement Phase 2 signal logic

---
*For detailed compilation guide: `Compile/COMPILE_GUIDE.md`* 