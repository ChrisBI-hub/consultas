SELECT [CuentaDeGasto]
      ,EstatusCGA
      ,CASE
	       WHEN [Fecha] IS NOT NULL THEN CAST([Fecha] AS DATE)
		   ELSE NULL
	  END AS [FECHA CGA]
	  ,Referencia as REFERENCIA
	  ,Pedimento AS PEDIMENTO
	  ,DescripcionMercancia AS MERCANCIA
	  ,Pedido AS PEDIDO
	  ,sObservacionesCGA AS OBSERVACIONES
	  ,Operacion AS OPERACION 
	  ,Cliente AS CLIENTE
	  ,PagosHechosME AS [PAGOS TERCEROS]
	  ,HonorariosME AS [HONORARIOS ABC]
	  ,ComplementariosME AS COMPLEMENTARIOS
	  ,IVA AS IVA
	  ,AnticiposME AS ANTICIPO
	  ,TotalME AS [TOTAL FACTURA]
	  ,LiquidacionME AS [PAGO PARCIAL]
	  ,SaldoME AS [SALDO FACTURA]
	  ,UUID AS UUID
   ,[DiasCred] AS [Días Credito]
 
 FROM [SIR].[Admin].[SIR_VT_CCEstadoDeCuenta]
  --WHERE Referencia IN ('VER-25-0602','25-007066','25-004887')
      WHERE Cliente  like '%INTERVET%' 
	  and [Fecha] > '2026-01-01'
    AND TotalME > 0
	--  AND EstatusCGA = 'FACTURADA'
	 -- AND DescripcionMercancia LIKE 'GESTORIA%'
	 ORDER BY  left(Fecha,10) ASC