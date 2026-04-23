TOP        = RFC8439.v
CHACHA	   = Chacha20.v
POLY	   = Poly1305.v

FSDB_CHA   = Chacha20.fsdb
FSDB_POLY  = Poly1305.fsdb

VCS        = vcs -R -full64 -sverilog
TARGET_DIR = src
SRC        = $(TOP).v

# GLS 模擬的檔案與設定
# ⚠️ 注意：請將下方的 CELL_LIB 替換成比賽當天提供的 Cell Library 路徑 (例如 tsmc13_neg.v)
CELL_LIB = tsmc13_neg.v
SRC_GLS  = tb.sv $(TOP)_syn.v -v $(CELL_LIB)

# 將 FSDB_NAME=$(FSDB_FILE) 加入到 DEFINE 中
DEFINE     = -debug_access+all +notimingcheck
# GLS 模擬通常需要開啟 SDF 標記 (取決於 testfixture 寫法，通常是 +define+SDF)
DEFINE_GLS = -debug_access+all +define+SDF +neg_tchk


all: compile

# 1. RTL 模擬
rtl:
	cd $(TARGET_DIR) && $(VCS) tb.sv $(SRC) $(DEFINE)

rtlcha:
	cd $(TARGET_DIR) && $(VCS) tb_chacha.sv Chacha20.v $(DEFINE)

rtlpoly:
	cd $(TARGET_DIR) && $(VCS) tb_poly1305.sv $(DEFINE)

nWavecha:
	cd $(TARGET_DIR) && nWave -ssf $(FSDB_CHA) &

nWavepoly:
	cd $(TARGET_DIR) && nWave -ssf $(FSDB_POLY) &


synthesize:
	dc_shell -x "set TOP_MODULE $(TOP); source syn.tcl"

# 3. 閘級模擬 (Gate-Level Simulation)
syn:
	$(VCS) $(SRC_GLS) $(DEFINE_GLS)

clean:
	rm -rf sim_* csrc ucli.key *.log
	rm -rf *.fsdb *.vcd
	rm -rf novas.* nWaveLog *.history
	rm -rf *_syn.* *.sdf *.ddc command.log default.svf

wave:
	nWave &