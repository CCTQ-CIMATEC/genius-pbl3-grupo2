#!/bin/bash

# uvm-verify - Script para executar testes UVM baseados no RISCV_test_list.sv

# Configurações
TEST_LIST_FILE="tb/tests/RISCV_test_list.sv"
XRUN_CMD="./bin/xrun.sh"
DEFAULT_SEED=0
FAILED_TESTS=()
FAIL_MESSAGES=()

# Verifica se o arquivo de lista de testes existe
if [ ! -f "$TEST_LIST_FILE" ]; then
    echo "Erro: Arquivo $TEST_LIST_FILE não encontrado!"
    exit 1
fi

# Extrai os nomes dos testes (removendo a extensão .sv)
TESTS=$(grep -oP '(?<=`include ")[^"]+(?=\.sv")' "$TEST_LIST_FILE")
NUM_TESTS=$(echo "$TESTS" | wc -w)
# Verifica se encontrou testes
if [ -z "$TESTS" ]; then
    echo "Nenhum teste encontrado em $TEST_LIST_FILE"
    exit 1
fi

echo "=============================================="
echo "  UVM Test Runner - RISCV Test Suite"
echo "=============================================="
echo "Testes detectados: $NUM_TESTS"
printf " - %s\n" $TESTS
echo "----------------------------------------------"
echo ""

# Função para verificar se houve falha no relatório UVM
check_uvm_report() {
    local output="$1"
    local fatal_errors=$(echo "$output" | grep -oP 'UVM_FATAL\s*:\s*\K\d+')
    
    if [ "$fatal_errors" -gt 0 ]; then
        return 1  # Houve falha
    else
        return 0  # Sucesso
    fi
}

# Função para extrair a mensagem de erro UVM_FATAL
extract_error_message() {
    echo "$1" | grep "UVM_FATAL" | sed 's/^.*uvm_test_top[^]]*\] //'
}

# Loop através de cada teste
for test_name in $TESTS; do
    echo "🚀 Executando teste: $test_name com seed $DEFAULT_SEED"
    echo "Comando: $XRUN_CMD -top RISCV_tb_top --name_of_test \"$test_name\" -c --vivado \"--R --sv_seed $DEFAULT_SEED\""
    
    # Executa o comando e captura a saída
    TEST_OUTPUT=$($XRUN_CMD -top RISCV_tb_top --name_of_test "$test_name" -c --vivado "--R --sv_seed $DEFAULT_SEED" 2>&1)
    TEST_STATUS=$?
    
    # Verifica o status e o relatório UVM
    if [ $TEST_STATUS -ne 0 ] || ! check_uvm_report "$TEST_OUTPUT"; then
        ERROR_MSG=$(extract_error_message "$TEST_OUTPUT")
        echo "❌ Teste $test_name falhou"
        echo $ERROR_MSG
        FAILED_TESTS+=("$test_name")
        FAIL_MESSAGES+=("$ERROR_MSG")
    else
        echo "✅ Teste $test_name concluído com sucesso"
    fi
    
    echo "----------------------------------------------"
done

echo "=============================================="
echo "📊 Relatório Final"
echo "=============================================="
echo "Total de testes executados: $NUM_TESTS"

if [ ${#FAILED_TESTS[@]} -gt 0 ]; then
    echo "❌ Testes que falharam (${#FAILED_TESTS[@]}):"
     for i in "${!FAILED_TESTS[@]}"; do
        echo " - ${FAILED_TESTS[$i]}: ${FAIL_MESSAGES[$i]}"
    done
    echo "=============================================="
    exit 1
else
    echo "🎉 Todos os testes passaram com sucesso!"
    echo "=============================================="
    exit 0
fi