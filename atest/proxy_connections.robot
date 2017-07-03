*** Settings ***
Force Tags          pybot   jybot
Resource       resources/common.robot
Test Teardown  Close All Connections

*** Variables ***
${PWD_COMMAND}      pwd
${HOME_DIR}         /home/test
${KEY DIR}          ${LOCAL TESTDATA}${/}keyfiles${/}proxy
${KEY}              ${KEY DIR}${/}id_rsa
${KEY USERNAME}     testkey

*** Test Cases ***
Login Through Proxy Machine
    ${sock}  Proxy Through  10.181.50.232  testkey  ${KEY}  10.255.11.71
    open connection  10.255.11.71  sock=${sock}
    Login  test  test  sock=${sock}
    ${result}  Execute Command  ${PWD_COMMAND}
    Should Be Equal  ${result}  ${HOME_DIR}

Switch Proxy Connection
    ${sock}  Proxy Through  10.181.50.232  testkey  ${KEY}  10.255.11.71
    ${conn1_id} =  Open Connection  10.255.11.71  sock=${sock}  alias=one  prompt=${PROMPT}
    Login  ${USERNAME}  ${PASSWORD}  sock=${sock}
    Write  cd /tmp
    Read Until Prompt
    ${conn_id2} =  Open Connection  ${HOST}  alias=second  prompt=${PROMPT}
    Login  ${USERNAME}  ${PASSWORD}
    ${prev id} =  Switch Connection  ${conn1_id}
    Should Be Equal  ${prev id}  ${conn_id2}
    Write  pwd
    ${output} =  Read Until Prompt
    Should Contain  ${output}  /tmp
    ${prev id} =  Switch Connection  second
    Write  pwd
    ${result} =  Read Until Prompt
    Should Contain  ${result}  ~