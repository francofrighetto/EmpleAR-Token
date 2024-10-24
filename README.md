# Proyecto Final - ERC20 Token "EmpleAR"

## Descripción del Proyecto

Este proyecto es parte del trabajo final para la cátedra de **Tecnologías DLT/Blockchain y Smart Contracts** en la carrera de **Ingeniería en Sistemas de Información**. El objetivo es la creación de un token ERC20 llamado **"EmpleAR"**,
diseñado para ser utilizado dentro de una plataforma que busca conectar trabajadores profesionales o de oficio con usuarios que soliciten sus servicios, simulando las transacciones entre los mismos.
Esta plataforma surge de la cátedra de **Proyecto Final**, la cual expondremos para completar nuestra carrera.

## Token "EmpleAR"

El token **EmpleAR (EAR)** es un token ERC20 estándar implementado en la red de prueba **Sepolia Testnet**, la cual simula las condiciones de la red principal de Ethereum (Mainnet) sin incurrir en costos reales de gas.

### Características del Token
- **Nombre del token**: EmpleAR
- **Símbolo**: EAR
- **Dirección del contrato**: 0x4930Fc192339d09030cbe9AaaF298a243B862881
- **Dirección del contrato en [Sepolia](https://sepolia.etherscan.io/address/0x4930Fc192339d09030cbe9AaaF298a243B862881)**
- **Funcionalidades adicionales**:
  - **Motivo en Transferencias**: Se requiere un motivo o categoría predefinida (como "plomería", "pintura", etc.) en cada transferencia, para asociarla a un tipo de trabajo.
  - **Modificadores**: Implementamos modificadores que restringen el acceso a ciertas funciones del contrato exclusivamente al dueño.
  - **Pausar/Despausar**: El contrato puede ser pausado o despausado en caso de detectar un problema o prevenir fallas.

## Objetivos del Proyecto

- Desarrollar un sistema de pagos y recompensas basado en blockchain para la plataforma de trabajo **EmpleAR**.
- Implementar un token ERC20 como medio de intercambio para recompensar los servicios de los trabajadores.
- Garantizar la trazabilidad, confianza y transparencia de las transacciones mediante una blockchain pública.

## Componentes Técnicos

- **Lenguaje**: Solidity
- **Red de Despliegue**: Sepolia Testnet.
- **Contrato ERC20**: Implementación del estándar ERC20 con extensiones que incluyen la gestión de motivos de transferencia y eventos personalizados.
- **Librerías utilizadas**: [OpenZeppelin](https://www.openzeppelin.com) para heredar las funcionalidades básicas de ERC20, control de acceso y pausabilidad.
- **IDE**: Utilizamos [Remix IDE](https://remix.ethereum.org) para compilar y desplegar el contrato. También usamos la opción **Flatten** de Remix para combinar el código del contrato con las librerías de OpenZeppelin.
- **Documentación NatSpec**: El contrato está documentado utilizando anotaciones NatSpec para facilitar la comprensión y uso del código.

## Interacción con el Contrato

Para interactuar con el contrato, los usuarios pueden utilizar la extensión de **MetaMask**, configurada con la red Sepolia. Esto permite realizar transacciones del tokens EmpleAR.


### Funcionalidades del Contrato

1. **Asignación de Tokens**: El dueño del contrato puede asignar tokens.
2. **Validación de Accesos**: Solo el dueño puede ejecutar ciertas funciones, como la asignación de tokens y la gestión de rubros.
3. **Pausar/Despausar**: El contrato puede ser pausado para prevenir fallas y reanudado cuando sea seguro.
4. **Transferencias de Tokens**: Los usuarios pueden transferir tokens, pero deben indicar el rubro del trabajo asociado a la transacción.
5. **Bloqueo/Desbloqueo de Direcciones**: Se puede bloquear o desbloquear una dirección si se considera necesario.
6. **Gestión de Rubros**: El dueño del contrato puede gestionar las categorías de rubros disponibles para las transferencias.
7. **Consulta de Información del Token**: Los usuarios pueden consultar el nombre, símbolo, cantidad de decimales y total de tokens emitidos.
8. **Renuncia de Propiedad**: El dueño puede renunciar a ser el propietario del contrato. 
9. **Aprobación de Pagos**: Las funcionalidades de aprobación y otras características básicas del estándar ERC20 están disponibles por defecto.

### Ejemplo de la función de transferencia del Token EmpleAR indicando el motivo

```solidity
    function transfer(
        address recipient,
        uint256 amount,
        string memory rubro
    )
        public
        notBlacklisted(_msgSender())
        notBlacklisted(recipient)
        validRubro(rubro)
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        emit TransferWithRubro(_msgSender(), recipient, amount, rubro);
        return true;
    }
