# ==========================================
# 檔案與模組名稱設定
# ==========================================
TOP        = RFC8439.v
CHACHA     = Chacha20.v
POLY       = Poly1305.v
QR         = Quarter_round.v

# 利用 basename 取得不含 .v 的名稱 (例如 RFC8439)，用於合成與 GLS
TOP_NAME   = $(basename $(TOP))
POLY_NAME  = $(basename $(POLY))

# 模擬產生的波形檔名
FSDB_CHA   = Chacha20.fsdb
FSDB_POLY  = Poly1305.fsdb

VCS        = vcs -R -full64 -sverilog
TARGET_DIR = src

# [修正] 直接等於 TOP，不再額外加 .v
SRC        = $(TOP)

# ==========================================
# 40nm GLS 模擬設定
# ==========================================
VERILOG_LIB_DIR = /usr/cad/designkit/CBDK_TSMC40_Arm_f2.0/CIC/Verilog
CELL_LIB = $(VERILOG_LIB_DIR)/sc9_cln40g_base_rvt.v -v $(VERILOG_LIB_DIR)/sc9_cln40g_base_rvt_udp.v

SRC_GLS    = tb.sv $(TOP_NAME)_syn.v -v $(CELL_LIB)
SRC_GLS_POLY = tb_poly1305.sv $(POLY_NAME)_syn.v -v $(CELL_LIB)

# 編譯參數
DEFINE     = -debug_access+all +notimingcheck
DEFINE_GLS = -debug_access+all +define+SDF +neg_tchk

# ==========================================
# 模擬與合成指令
# ==========================================

all: rtlpoly

# 1. RTL 模擬
rtl:
	cd $(TARGET_DIR) && $(VCS) tb.sv $(TOP) $(CHACHA) $(POLY) $(QR) $(DEFINE)

rtlcha:
	cd $(TARGET_DIR) && $(VCS) tb_chacha.sv $(CHACHA) $(QR) $(DEFINE)

rtlpoly:
	cd $(TARGET_DIR) && $(VCS) tb_poly1305.sv $(POLY) $(DEFINE)

# 2. 合成 (Synthesis)
synthesize:
	cd $(TARGET_DIR) && dc_shell -x "set TOP_MODULE $(TOP_NAME); source syn.tcl"

synthesizepoly:
	cd $(TARGET_DIR) && dc_shell -x "set TOP_MODULE $(POLY_NAME); source syn.tcl"

# 3. 閘級模擬 (Gate-Level Simulation)
syn:
	cd $(TARGET_DIR) && $(VCS) $(SRC_GLS) $(DEFINE_GLS)

synpoly:
	cd $(TARGET_DIR) && $(VCS) tb_poly1305.sv Poly1305_syn.v $(CELL_LIB) $(DEFINE_GLS)
# 4. 波形觀測
nWavecha:
	cd $(TARGET_DIR) && nWave -ssf $(FSDB_CHA) &

nWavepoly:
	cd $(TARGET_DIR) && nWave -ssf $(FSDB_POLY) &

wave:
	nWave &

# 5. 清理環境
clean:
	rm -rf simv simv.daidir sim_* csrc ucli.key *.log
	rm -rf *.fsdb *.vcd novas.* nWaveLog *.history
	rm -rf *_syn.v *.sdf *.ddc command.log default.svf
	cd $(TARGET_DIR) && rm -rf simv simv.daidir sim_* csrc ucli.key *.log *.fsdb *.vcd novas.* nWaveLog *.history *.sdf *.ddc default.svf WORK