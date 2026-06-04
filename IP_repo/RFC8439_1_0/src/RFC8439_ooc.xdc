# =========================================================================
# Out-of-Context (OOC) Constraints for Custom Crypto IP
# =========================================================================

# 定義時脈週期 (假設您的系統時脈是 100 MHz，週期就是 10.000 奈秒)
# -name 後面可以隨便取名，通常就叫 clk
# [get_ports clk] 這裡的 clk 必須完全對應您 Verilog 頂層模組宣告的時脈變數名稱
create_clock -period 10.000 -name clk [get_ports clk]

# (選用) 如果您的 AXI-Lite 介面跟核心運算介面是用同一個時脈，寫上面一行就夠了。
# 如果未來您有兩個不同的時脈 (例如 AXI 跑 50MHz，加密核心跑 200MHz)，才需要定義第二組：
# create_clock -period 5.000 -name core_clk [get_ports core_clk]