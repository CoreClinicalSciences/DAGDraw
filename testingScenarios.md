# DAG Tool Testing Scenarios (shinytest2)

## Naming Base Nodes

### Scenario a: Basic DAG

**Action:**

1. Name treatment `x` and response `y`.

**Checks:**

- Check that the DAG contains a node for `x` and `y`.
- Check that the node display contains a card for `x` and `y`.

### Scenario b: Transportability DAG

**Action:**

- Name treatment `x` and response `y`.
- Turn on the transportability option.

**Checks:**

- Check that the DAG contains a node for `x`, `y`, and `participation`.
- Check that the node display contains a card for `x`, `y`, and `participation`.

### Scenario c: Incorrect User Input

**Action:**

- Name treatment `thisislongstring` and response `y`. Set names.
- Name treatment `x` and response `thisislongstring`. Set names.
- Name treatment `thisislongstringone` and response `thisislongstring`. Set names.
- Name treatment `test` and response `test`. Set names.
- Name treatment `node` and response `y`. Set names.
- Name treatment `x` and response `graph`. Set names.
- Name treatment `x` and leave the response blank. Set names.
- Name treatment "test one" and the response `y`. Set names.
- Name treatment "test!" and the response "test@#$". Set names.

**Checks:**

- Check that all give errors and don’t advance the user.

## Adding Nodes

**Pre-Conditions:**

- Name treatment `x` and response `y`. Set names.

### Scenario a: Adding a New Node

**Action:**

- Go to the Add New Node tab and add a node with the following attributes:
  - Name: `newNode`
  - Children: `x`
  - Add node

**Checks:**

- Check that the DAG contains a node for `newNode`.
- Check that the node display contains a card for `newNode`.

### Scenario b: Adding a Node with an Invalid Name

**Action:**

- Go to the Add New Node tab and try to add a node with the following attributes:
  - Name: `newNode*`
  - Children: `x`

  - Name: `new node`
  - Children: `x`

  - Name: `node`
  - Children: `x`

  - Name: `thisNameIsTooLong`
  - Children: `x`

  - Name: 
  - Children: `x`

  - Name: `x`
  - Children: `x`

  - Name: `newNode`
  - Children: `x`
  - Conditioned and Unmeasured are turned on

**Checks:**

- Check that all give errors and don’t advance the user.

### Scenario c: Adding an Unmeasured Node

**Action:**

- Go to the Add New Node tab and add a node with the following attributes:
  - Name: `newNode`
  - Unmeasured: True
  - Children: `x`
  - Add node

**Checks:**

- Check that the DAG contains a node for `newNode`.
- Check that the node display contains a card for `newNode` and when edit mode is on, unmeasured.

### Scenario d: Adding a Conditioned Node

**Action:**

- Go to the Add New Node tab and add a node with the following attributes:
  - Name: `newNode`
  - Unmeasured: True
  - Children: `x`

**Checks:**

- Check that the DAG contains a node for `newNode` that is blue.
- Check that the node display contains a card for `newNode` and that when edit mode is on, the conditioned toggle is on.

### Scenario e: Adding an Unmeasured Node

**Action:**

- Go to the Add New Node tab and add a node with the following attributes:
  - Name: `newNode`
  - Conditioned: True
  - Children: `x`

**Checks:**

- Check that the DAG contains a node for `newNode`.
- Check that the node display contains a card for `newNode` and when edit mode is on, the unmeasured toggle is on.

## Visualizing Open Back Door Paths

**Pre-Conditions:**

- Name treatment `x` and response `y`. Set names.

### Scenario a: Conditioning on a Collider

**Action:**

- Add a new node named `a` with `y` as a child.
- Add a new node named `e` with `x` and `a` as parents.
- Edit node `e` and make it conditioned.
- View Open Back Door Paths.

**Checks:**

- Check that the Open Back Door DAG contains no open paths before editing.
- After editing, check that the Open Back Door DAG contains a red line to show the open path.
- Check that a card for the open back door path is there.
- Check that a warning appears to notify the user of their conditioning.

### Scenario b: Open Path

**Action:**

- Name treatment `x` and response `y`.
- Turn on the transportability option.

**Checks:**

- Check that the DAG contains a node for `x`, `y`, and `participation`.
- Check that the node display contains a card for `x`, `y`, and `participation`.

## R-Code

**Pre-Conditions:**

- Name treatment `x` and response `y`. Set names.

### Scenario a: R Code

**Action:**

- View the R Code tab.

**Checks:**

- Make sure that R code is correct.

### Scenario b: R-Code Copyable?

## Editing Nodes

**Pre-Conditions:**

- Name treatment `x` and response `y`. Set names.
- Add a node named `newNode` connected to `x` and `y`.

### Scenario a: Editing Parent Connections

**Action:**

- Edit `newNode` and remove connection to `x`.

**Checks:**

- Node `newNode` only displays a connection to `y`.

### Scenario b: Editing Child Connections

**Action:**

- Edit `x` and remove the connection to `newNode`.

**Checks:**

- Node `x` only displays a connection to `y`.

### Scenario c: Editing Conditioning

**Action:**

- Edit `x` and remove the connection to `newNode`.

**Checks:**

- `x` only displays a connection to `y`.

### Scenario d: Editing Unmeasured

### Scenario e: Editing Conditioning and Unmeasured

### Scenario f: Remove All Connections from a Node

### Scenario g: Edit Base Nodes (Make User Not Have Accessibility to Error-Creating Changes)

- Can I check for an error (try-except) before the dashboard crashes?
